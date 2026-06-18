//
//  MiloAgentConnectionStatus.swift
//  Milo
//

import Foundation

enum MiloAgentConnectionStatus: String, Codable, Equatable {
    case notConnected
    case connecting
    case connected
    case testing
    case testPassed
    case testFailed
    case disconnected
    case failed

    var title: String {
        switch self {
        case .notConnected: return "Not Connected"
        case .connecting:   return "Connecting"
        case .connected:    return "Connected"
        case .testing:      return "Testing"
        case .testPassed:   return "Test Passed"
        case .testFailed:   return "Test Failed"
        case .disconnected: return "Disconnected"
        case .failed:       return "Failed"
        }
    }
}
