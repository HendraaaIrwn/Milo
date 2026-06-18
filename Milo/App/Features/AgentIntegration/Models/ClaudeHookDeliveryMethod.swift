//
//  ClaudeHookDeliveryMethod.swift
//  Milo
//
//  PRIVACY: Tags the source of a Claude hook event for diagnostics only.
//  No payload data is associated with this enum — it lives alongside the
//  sanitized event so the UI can label fallback vs primary path delivery.
//

import Foundation

enum ClaudeHookDeliveryMethod: String, Codable, Equatable {
    case hookCommand
    case localReceiver
    case offlineQueue
    case processWatcherFallback

    var title: String {
        switch self {
        case .hookCommand:             return "Hook Command"
        case .localReceiver:           return "Local Receiver"
        case .offlineQueue:            return "Offline Queue"
        case .processWatcherFallback:  return "Process Watcher Fallback"
        }
    }
}
