//
//  MiloAgentDetector.swift
//  Milo
//
//  PRIVACY: Polls running processes every N seconds using /bin/ps.
//  Only runs detectors for explicitly connected agents. Never all at once.
//  Runs on background thread — never blocks MainActor.
//
//  Per-agent polling:
//  - Xcode Build: 1.5s (short GUI builds would otherwise be missed)
//  - Other agents: 5s
//

import Foundation

final class MiloAgentDetector {
    private let processListProvider = ProcessListProvider()
    private let statusStore: MiloAgentStatusStore
    private let settingsStore: MiloAgentIntegrationsSettingsStore

    private var pollingTask: Task<Void, Never>?
    private var isRunning = false
    private var lastRunningEvent: MiloAgentEvent?
    private var lastPublishedSnapshot: AgentStatusSnapshot = .idle
    private var hasCompletedInitialPoll = false

    init(
        statusStore: MiloAgentStatusStore,
        settingsStore: MiloAgentIntegrationsSettingsStore
    ) {
        self.statusStore = statusStore
        self.settingsStore = settingsStore
    }

    private var connectedTypes: [MiloAgentType] {
        settingsStore.configs
            .filter { $0.isConnected && $0.isEnabled }
            .filter { config in
                // The Claude Code hooks integration is the primary path.
                // The process watcher is a best-effort fallback and only
                // runs when the user explicitly opts in. The other agents
                // have no hooks equivalent yet and run as before.
                if config.agentType == .claudeCode {
                    return config.fallbackEnabled
                }
                return true
            }
            .map(\.agentType)
    }

    private func currentPollingInterval() -> TimeInterval {
        let enabled = connectedTypes
        if enabled.contains(.xcodeBuild) {
            return 1.5
        }
        return 5.0
    }

    func start() {
        stop()
        guard !connectedTypes.isEmpty else {
            Task { @MainActor in statusStore.clear() }
            return
        }
        startPolling()
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
        isRunning = false
        lastRunningEvent = nil
        lastPublishedSnapshot = .idle
        hasCompletedInitialPoll = false
        Task { @MainActor in statusStore.clear() }
    }

    func refreshConnectedAgents() {
        if connectedTypes.isEmpty {
            stop()
        } else if !isRunning {
            start()
        }
    }

    private func startPolling() {
        isRunning = true
        pollingTask = Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            while !Task.isCancelled {
                await self.pollOnce()
                let interval = await MainActor.run { self.currentPollingInterval() }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    private func pollOnce() async {
        let types = await MainActor.run { connectedTypes }

        #if DEBUG
        let enabledNames = types.map(\.displayName).joined(separator: ", ")
        MiloAgentDebugLogger.log("Enabled agents: \(enabledNames)")
        #endif

        guard !types.isEmpty else {
            await MainActor.run { publishIfChanged(nil) }
            return
        }

        let processes = await processListProvider.currentProcesses(includeCommandArguments: false)

        #if DEBUG
        MiloAgentDebugLogger.log("Process count: \(processes.count)")
        #endif

        let event = detectAgentEvent(from: processes, types: types)

        #if DEBUG
        MiloAgentDebugLogger.log("Detected event: \(event?.title ?? "none")")
        #endif

        if let event {
            hasCompletedInitialPoll = true
            lastRunningEvent = event
            await MainActor.run { publishIfChanged(event) }
        } else {
            handleNoDetectedAgent()
            hasCompletedInitialPoll = true
        }
    }

    private func handleNoDetectedAgent() {
        guard let previous = lastRunningEvent else {
            Task { @MainActor in publishIfChanged(nil) }
            return
        }
        guard hasCompletedInitialPoll else {
            lastRunningEvent = nil
            Task { @MainActor in publishIfChanged(nil) }
            return
        }
        let doneEvent = makeFinishedEvent(from: previous)
        lastRunningEvent = nil
        Task { @MainActor in publishIfChanged(doneEvent) }
    }

    private func makeFinishedEvent(from previous: MiloAgentEvent) -> MiloAgentEvent {
        let endedAt = Date()
        let duration: TimeInterval? = previous.startedAt.map { endedAt.timeIntervalSince($0) }

        switch previous.agentType {
        case .xcodeBuild:
            return MiloAgentEvent(
                agentType: .xcodeBuild, state: .done,
                title: "Xcode build finished",
                detail: "MILO detected the build process ended.",
                startedAt: previous.startedAt, endedAt: endedAt,
                durationSeconds: duration, exitCode: nil
            )
        default:
            return MiloAgentEvent(
                agentType: previous.agentType, state: .done,
                title: "\(previous.agentType.displayName) finished",
                detail: "MILO detected the task finished.",
                startedAt: previous.startedAt, endedAt: endedAt,
                durationSeconds: duration, exitCode: nil
            )
        }
    }

    private func detectAgentEvent(
        from processes: [MiloAgentProcessSnapshot],
        types: [MiloAgentType]
    ) -> MiloAgentEvent? {
        let detectors = makeDetectors(for: types)
        for detector in detectors {
            if let event = detector.detect(from: processes, previous: lastRunningEvent) {
                return event
            }
        }
        return nil
    }

    private func makeDetectors(for types: [MiloAgentType]) -> [MiloAgentDetectorProtocol] {
        types.compactMap { type in
            switch type {
            case .codex:           return CodexAgentDetector()
            case .claudeCode:      return ClaudeCodeAgentDetector()
            case .cursorAgent:     return CursorAgentDetector()
            case .xcodeBuild:      return XcodeBuildDetector()
            case .genericTerminal: return GenericTerminalCommandDetector()
            case .unknown:         return nil
            }
        }
    }

    @MainActor
    private func publishIfChanged(_ event: MiloAgentEvent?) {
        let snapshot = AgentStatusSnapshot(event)
        guard snapshot != lastPublishedSnapshot else { return }
        lastPublishedSnapshot = snapshot
        if let event { statusStore.update(event) } else { statusStore.clear() }
    }
}

private struct AgentStatusSnapshot: Equatable {
    let state: MiloAgentState; let agentType: MiloAgentType; let title: String
    static let idle = AgentStatusSnapshot(state: .idle, agentType: .unknown, title: "")
    init(state: MiloAgentState, agentType: MiloAgentType, title: String) {
        self.state = state; self.agentType = agentType; self.title = title
    }
    init(_ event: MiloAgentEvent?) {
        self.state = event?.state ?? .idle
        self.agentType = event?.agentType ?? .unknown
        self.title = event?.title ?? ""
    }
}