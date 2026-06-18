//
//  MiloAgentIntegrationConnectionState.swift
//  Milo
//

import Foundation

enum MiloAgentIntegrationConnectionState: Codable, Equatable {
    case disabled
    case notConnected
    case connecting
    case connected
    case failed(String)

    var title: String {
        switch self {
        case .disabled:     return "Disabled"
        case .notConnected: return "Not Connected"
        case .connecting:   return "Connecting"
        case .connected:    return "Connected"
        case .failed:       return "Failed"
        }
    }
}
