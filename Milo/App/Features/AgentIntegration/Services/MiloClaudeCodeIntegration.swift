//
//  MiloClaudeCodeIntegration.swift
//  Milo
//
//  Facade for the Claude Code integration. Owns the local receiver,
//  the bubble queue, and the event handler. The app calls start()
//  when the user connects Claude Code and stop() on disconnect.
//

import Foundation
import Combine
import OSLog

@MainActor
final class MiloClaudeCodeIntegration: ObservableObject {
    private let logger = Logger(subsystem: "com.milo", category: "ClaudeIntegration")

    private let statusStore: MiloAgentStatusStore
    private let overlayCoordinator: MiloOverlayCoordinator
    private let petState: MiloFloatingPetState
    private let settingsStore: MiloAgentIntegrationsSettingsStore
    private let miloctlBundleURL: URL?

    private(set) var receiver: MiloLocalAgentEventReceiver?
    private(set) var handler: UnifiedAgentEventHandler?
    private(set) var bubbleQueue: MiloAgentEventBubbleQueue?

    @Published private(set) var isRunning: Bool = false
    @Published private(set) var lastError: String?
    @Published private(set) var lastReceivedEvent: UnifiedAgentHookEvent?

    private let configStorageKey = "Milo.AgentReceiverConfig.v1"

    init(
        statusStore: MiloAgentStatusStore,
        overlayCoordinator: MiloOverlayCoordinator,
        petState: MiloFloatingPetState,
        settingsStore: MiloAgentIntegrationsSettingsStore,
        miloctlBundleURL: URL?
    ) {
        self.statusStore = statusStore
        self.overlayCoordinator = overlayCoordinator
        self.petState = petState
        self.settingsStore = settingsStore
        self.miloctlBundleURL = miloctlBundleURL
    }

    var miloctlInstalled: Bool {
        guard let url = miloctlBundleURL else { return false }
        return FileManager.default.isExecutableFile(atPath: url.path)
    }

    var miloctlInstallPath: String? {
        miloctlBundleURL?.path
    }

    func start() {
        guard !isRunning else { return }

        let queue = MiloAgentEventBubbleQueue(overlayCoordinator: overlayCoordinator)
        let handler = UnifiedAgentEventHandler(
            statusStore: statusStore,
            overlayCoordinator: overlayCoordinator,
            bubbleQueue: queue,
            petState: petState
        )

        let config = loadOrCreateConfig()
        let receiver = MiloLocalAgentEventReceiver(
            config: config,
            handler: { [weak self, weak handler] event in
                Task { @MainActor in
                    handler?.handle(event)
                    self?.lastReceivedEvent = event
                    self?.markReceived(event)
                }
            },
            onStateChange: { [weak self] running in
                Task { @MainActor in
                    self?.applyRunningState(running)
                }
            }
        )

        self.bubbleQueue = queue
        self.handler = handler
        self.receiver = receiver
        receiver.start()

        MiloAgentDebugLogger.log("Claude receiver starting on \(config.host):\(config.port)")
    }

    func stop() {
        receiver?.stop()
        receiver = nil
        bubbleQueue?.clear()
        bubbleQueue = nil
        handler = nil
        isRunning = false
        applyRunningState(false)
    }

    /// Round-trip test: invokes the bundled `miloctl claude-event --event Test`
    /// and waits up to 4 seconds for the receiver to receive the test event.
    func runTest(agentType: MiloAgentType, completion: @escaping (Bool, String?) -> Void) {
        guard let miloctlURL = miloctlBundleURL else {
            completion(false, "miloctl not bundled in this build.")
            return
        }
        guard isRunning else {
            completion(false, "Local receiver is not running.")
            return
        }

        let payload = "{\"event\":\"UserPromptSubmit\",\"source\":\"milo-test\"}\n"
        guard let data = payload.data(using: .utf8) else {
            completion(false, "Failed to encode test payload.")
            return
        }

        let process = Process()
        process.executableURL = miloctlURL
        process.arguments = [agentType == .codex ? "codex-event" : "claude-event", "--event", "UserPromptSubmit"]
        let stdinPipe = Pipe()
        process.standardInput = stdinPipe
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        do {
            try process.run()
            stdinPipe.fileHandleForWriting.write(data)
            try? stdinPipe.fileHandleForWriting.close()
        } catch {
            completion(false, "Failed to run miloctl: \(error.localizedDescription)")
            return
        }

        // Wait for the receiver to report the test event via lastReceivedEvent.
        let deadline = Date().addingTimeInterval(4)
        Task { @MainActor [weak self] in
            while Date() < deadline {
                if let last = self?.lastReceivedEvent,
                   last.agentType == agentType,
                   last.eventName == "UserPromptSubmit" {
                    self?.bubbleQueue?.enqueueTestSuccess(agentType: agentType)
                    completion(true, nil)
                    return
                }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            self?.bubbleQueue?.enqueueTestFailure(agentType: agentType)
            completion(false, "MILO could not receive the \(agentType.displayName) hook test.")
        }
    }

    private func applyRunningState(_ running: Bool) {
        isRunning = running
        // Mirror to the per-agent settings store so the UI status reflects reality.
        for type in [MiloAgentType.codex, .claudeCode] {
            var config = settingsStore.config(for: type)
            config.localReceiverRunning = running
            if running {
                config.miloctlInstalled = miloctlInstalled
            }
            settingsStore.update(config)
        }
    }

    private func markReceived(_ event: UnifiedAgentHookEvent) {
        var config = settingsStore.config(for: event.agentType)
        config.lastHookEventName = event.eventName
        config.lastHookReceivedAt = event.receivedAt
        config.lastDetectedAt = event.receivedAt
        settingsStore.update(config)
    }

    func observeEvents() -> AnyPublisher<UnifiedAgentHookEvent, Never> {
        handler?.$lastReceivedEvent
            .compactMap { $0 }
            .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    }

    private func loadOrCreateConfig() -> MiloLocalAgentEventReceiverConfig {
        if let existing = loadConfigFromDisk() {
            return existing
        }
        let new = MiloLocalAgentEventReceiverConfig.makeDefault()
        saveConfigToDisk(new)
        return new
    }

    private func loadConfigFromDisk() -> MiloLocalAgentEventReceiverConfig? {
        guard let data = try? Data(contentsOf: configFileURL) else { return nil }
        return try? JSONDecoder().decode(MiloLocalAgentEventReceiverConfig.self, from: data)
    }

    private func saveConfigToDisk(_ config: MiloLocalAgentEventReceiverConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        try? FileManager.default.createDirectory(
            at: configFileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: configFileURL, options: [.atomic])
    }

    private var configFileURL: URL {
        let support = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return support
            .appendingPathComponent("MILO", isDirectory: true)
            .appendingPathComponent("agent-receiver.json")
    }
}
