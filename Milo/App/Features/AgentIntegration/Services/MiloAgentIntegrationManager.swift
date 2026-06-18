//
//  MiloAgentIntegrationManager.swift
//  Milo
//
//  PRIVACY: Manages the safe connection lifecycle for Agent Integrations.
//  Detector only starts after manual user opt-in. Circuit breaker prevents
//  repeated failure loops. Process scanning never happens before connect.
//

import Foundation
import Combine

enum MiloAgentIntegrationError: Error {
    case timeout
    case preflightFailed
    case detectorUnavailable
    case disabledAfterRepeatedFailures
}

@MainActor
final class MiloAgentIntegrationManager: ObservableObject {
    @Published private(set) var connectionState: MiloAgentIntegrationConnectionState = .notConnected
    @Published private(set) var connectionProgressMessage: String = ""

    let detector: MiloAgentDetector
    let settingsStore: MiloAgentDetectionSettingsStore
    let statusStore: MiloAgentStatusStore
    private let preflightService: MiloAgentIntegrationPreflightService

    private var failureCount: Int {
        get { UserDefaults.standard.integer(forKey: "MiloAgentIntegration.failureCount") }
        set { UserDefaults.standard.set(newValue, forKey: "MiloAgentIntegration.failureCount") }
    }

    init(
        detector: MiloAgentDetector,
        settingsStore: MiloAgentDetectionSettingsStore,
        statusStore: MiloAgentStatusStore,
        preflightService: MiloAgentIntegrationPreflightService
    ) {
        self.detector = detector
        self.settingsStore = settingsStore
        self.statusStore = statusStore
        self.preflightService = preflightService

        if settingsStore.settings.isEnabled && settingsStore.settings.isConnected {
            connectionState = .notConnected
        } else {
            connectionState = .notConnected
        }
    }

    func connect() {
        guard connectionState != .connecting else { return }

        if failureCount >= settingsStore.settings.maxStartupFailuresBeforeDisable {
            connectionState = .failed("Agent Integration was disabled after repeated startup failures.")
            return
        }

        connectionState = .connecting
        connectionProgressMessage = "Preparing Agent Integrations..."

        Task {
            do {
                try await connectSafely()
                await MainActor.run {
                    var s = settingsStore.settings
                    s.isEnabled = true
                    s.isConnected = true
                    s.autoStartOnLaunch = false
                    settingsStore.settings = s
                    failureCount = 0
                    connectionState = .connected
                    connectionProgressMessage = "Connected"
                }
            } catch {
                await MainActor.run { handleConnectionFailure(error) }
            }
        }
    }

    func disconnect() {
        detector.stop()
        var s = settingsStore.settings
        s.isEnabled = false
        s.isConnected = false
        s.autoStartOnLaunch = false
        settingsStore.settings = s
        connectionState = .notConnected
        connectionProgressMessage = ""
    }

    func retry() { connect() }

    func keepDisabled() {
        detector.stop()
        var s = settingsStore.settings
        s.isEnabled = false
        s.isConnected = false
        s.autoStartOnLaunch = false
        settingsStore.settings = s
        connectionState = .disabled
        connectionProgressMessage = ""
    }

    func simulateEvent(_ event: MiloAgentEvent) {
        statusStore.update(event)
    }

    private func connectSafely() async throws {
        let timeout = settingsStore.settings.connectionTimeoutSeconds
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await self.runConnectionFlow() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw MiloAgentIntegrationError.timeout
            }
            guard let _ = try await group.next() else { throw MiloAgentIntegrationError.preflightFailed }
            group.cancelAll()
        }
    }

    private func runConnectionFlow() async throws {
        await MainActor.run { connectionProgressMessage = "Checking safe process access..." }
        try await preflightService.runPreflight()

        await MainActor.run { connectionProgressMessage = "Starting lightweight detector..." }
        detector.start()

        await MainActor.run { connectionProgressMessage = "Finalizing connection..." }
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    private func handleConnectionFailure(_ error: Error) {
        detector.stop()
        failureCount += 1

        var s = settingsStore.settings
        s.isEnabled = false
        s.isConnected = false
        s.autoStartOnLaunch = false
        settingsStore.settings = s

        if failureCount >= s.maxStartupFailuresBeforeDisable {
            connectionState = .failed("Agent Integration was disabled after repeated startup failures.")
            connectionProgressMessage = "Disabled for safety."
            return
        }

        if error is MiloAgentIntegrationError {
            connectionState = .failed("Connection timed out. MILO kept Agent Integration disabled for safety.")
        } else {
            connectionState = .failed("MILO could not start Agent Integration safely.")
        }
        connectionProgressMessage = ""
    }
}
