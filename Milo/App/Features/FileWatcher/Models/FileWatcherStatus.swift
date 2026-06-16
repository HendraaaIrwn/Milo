//
//  FileWatcherStatus.swift
//  Milo
//

import Foundation

enum FileWatcherStatus: Codable, Equatable {
    case stopped
    case running
    case paused
    case error(message: String)

    var title: String {
        switch self {
        case .stopped: return "Stopped"
        case .running: return "Running"
        case .paused: return "Paused"
        case .error: return "Error"
        }
    }

    var isActive: Bool {
        switch self {
        case .running: return true
        default: return false
        }
    }
}
