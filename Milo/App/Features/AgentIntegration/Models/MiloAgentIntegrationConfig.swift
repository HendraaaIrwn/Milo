//
//  MiloAgentIntegrationConfig.swift
//  Milo
//

import Foundation

struct MiloAgentIntegrationConfig: Identifiable, Codable, Equatable {
    var id: MiloAgentType { agentType }
    var agentType: MiloAgentType

    var isEnabled: Bool = false
    var isConnected: Bool = false
    var autoStartOnLaunch: Bool = false

    var connectionStatus: MiloAgentConnectionStatus = .notConnected

    var allowCommandArgumentDetection: Bool = false
    var allowSafeLogKeywordDetection: Bool = false

    var lastConnectedAt: Date?
    var lastTestedAt: Date?
    var lastDetectedAt: Date?
    var lastErrorMessage: String?

    var pollingIntervalSeconds: TimeInterval = 5.0

    // Claude Code hooks integration fields.
    var fallbackEnabled: Bool = false
    var lastHookEventName: String?
    var lastHookReceivedAt: Date?
    var miloctlInstalled: Bool = false
    var localReceiverRunning: Bool = false
}
