//
//  MiloAgentDetectionSettings.swift
//  Milo
//

import Foundation

struct MiloAgentDetectionSettings: Codable, Equatable {
    var isEnabled: Bool = false
    var isConnected: Bool = false
    var autoStartOnLaunch: Bool = false

    var showFloatingBadge: Bool = true
    var notifyOnDone: Bool = true
    var notifyOnFailed: Bool = true
    var playSoundOnDone: Bool = true
    var playSoundOnFailed: Bool = true

    var detectCodex: Bool = true
    var detectClaudeCode: Bool = true
    var detectCursorAgent: Bool = false
    var detectXcodeBuild: Bool = true
    var detectGenericTerminalCommands: Bool = false

    var allowSafeLogKeywordDetection: Bool = false

    var launchDelaySeconds: TimeInterval = 5.0
    var pollingIntervalSeconds: TimeInterval = 5.0
    var connectionTimeoutSeconds: TimeInterval = 8.0
    var maxStartupFailuresBeforeDisable: Int = 3

    var completedBadgeDurationSeconds: TimeInterval = 4.0
    var failedBadgeDurationSeconds: TimeInterval = 5.0
    var reviewBadgeDurationSeconds: TimeInterval = 6.0
}
