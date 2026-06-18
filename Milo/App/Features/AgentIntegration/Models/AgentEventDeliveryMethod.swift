//
//  AgentEventDeliveryMethod.swift
//  Milo
//

import Foundation

enum AgentEventDeliveryMethod: String, Codable, Equatable {
    case hookCommand
    case localReceiver
    case offlineQueue
    case processWatcherFallback
}
