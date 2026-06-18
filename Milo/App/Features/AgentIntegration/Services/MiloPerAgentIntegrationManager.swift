//
//  MiloPerAgentIntegrationManager.swift
//  Milo
//
//  PRIVACY: Manages per-agent connection lifecycle independently.
//  Only starts detectors for explicitly connected agents.
//  No global Connect All — each agent is managed separately.
//

import Foundation
import Combine

@MainActor
final class MiloPerAgentIntegrationManager: ObservableObject {
    let settingsStore: MiloAgentIntegrationsSettingsStore
    let detector: MiloAgentDetector
    let statusStore: MiloAgentStatusStore
    private let testService: MiloAgentConnectionTestService

    /// Hooks the app uses to react when a Claude Code integration connects
    /// or disconnects (starts/stops the local receiver).
    var onAgentConnected: ((MiloAgentType) -> Void)?
    var onAgentDisconnected: ((MiloAgentType) -> Void)?

    @Published private(set) var activeOperationAgent: MiloAgentType?

    var connectedCount: Int {
        settingsStore.configs.filter { $0.isConnected }.count
    }

    var totalCount: Int { settingsStore.configs.count }

    init(
        settingsStore: MiloAgentIntegrationsSettingsStore,
        detector: MiloAgentDetector,
        statusStore: MiloAgentStatusStore,
        testService: MiloAgentConnectionTestService
    ) {
        self.settingsStore = settingsStore
        self.detector = detector
        self.statusStore = statusStore
        self.testService = testService
    }

    func connect(_ agentType: MiloAgentType) {
        guard activeOperationAgent == nil else { return }
        activeOperationAgent = agentType
        settingsStore.setStatus(.connecting, for: agentType)

        Task {
            do {
                try await withTimeout(seconds: 8) {
                    try await self.testService.preflight(agentType)
                }
                await MainActor.run {
                    settingsStore.setStatus(.connected, for: agentType)
                    detector.refreshConnectedAgents()
                    activeOperationAgent = nil
                    onAgentConnected?(agentType)
                }
            } catch {
                await MainActor.run {
                    settingsStore.setStatus(.failed, for: agentType,
                        errorMessage: "MILO could not connect \(agentType.displayName) safely.")
                    activeOperationAgent = nil
                }
            }
        }
    }

    func testConnection(_ agentType: MiloAgentType) {
        guard activeOperationAgent == nil else { return }
        activeOperationAgent = agentType
        settingsStore.setStatus(.testing, for: agentType)

        Task {
            do {
                try await withTimeout(seconds: 8) {
                    try await self.testService.test(agentType)
                }
                await MainActor.run {
                    settingsStore.setStatus(.testPassed, for: agentType)
                    activeOperationAgent = nil
                }
            } catch {
                await MainActor.run {
                    settingsStore.setStatus(.testFailed, for: agentType,
                        errorMessage: "Test failed for \(agentType.displayName).")
                    activeOperationAgent = nil
                }
            }
        }
    }

    func disconnect(_ agentType: MiloAgentType) {
        settingsStore.disconnect(agentType)
        detector.refreshConnectedAgents()
        onAgentDisconnected?(agentType)
    }

    func disconnectAll() {
        let previouslyConnected = settingsStore.configs.filter { $0.isConnected }.map(\.agentType)
        settingsStore.disconnectAll()
        detector.refreshConnectedAgents()
        previouslyConnected.forEach { onAgentDisconnected?($0) }
    }

    func simulateEvent(_ event: MiloAgentEvent) {
        statusStore.update(event)
    }

    private func withTimeout(seconds: TimeInterval, operation: @escaping () async throws -> Void) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw MiloAgentIntegrationError.timeout
            }
            try await group.next()
            group.cancelAll()
        }
    }
}
