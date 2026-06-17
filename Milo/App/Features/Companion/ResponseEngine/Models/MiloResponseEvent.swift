//
//  MiloResponseEvent.swift
//  Milo
//

import Foundation

enum MiloResponseEvent: String, Codable, Equatable {
    case miloClicked
    case typingDetected
    case returnedFromIdle
    case todoAdded
    case reminderDue
    case pomodoroCompleted
    case breakSkipped
    case dailyMilestone
    case lateNightCoding
    case system
}
