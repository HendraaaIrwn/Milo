//
//  MiloBubbleSource.swift
//  Milo
//

import Foundation

enum MiloBubbleSource: String, Codable {
    case click
    case typing
    case addTodo
    case reminderSaved
    case reminderDue
    case todoDue
    case pomodoro
    case breakNudge
    case idleNudge
    case agent
    case system

    var defaultPriority: MiloBubblePriority {
        switch self {
        case .reminderDue, .todoDue:
            return .critical
        case .pomodoro, .breakNudge, .agent:
            return .high
        case .click, .addTodo, .reminderSaved, .system:
            return .normal
        case .typing, .idleNudge:
            return .low
        }
    }

    var defaultDuration: TimeInterval {
        switch self {
        case .reminderDue, .todoDue:
            return 5
        case .pomodoro, .breakNudge, .agent:
            return 4
        case .addTodo, .reminderSaved:
            return 3
        case .click:
            return 3
        case .typing, .idleNudge:
            return 2.5
        case .system:
            return 3
        }
    }
}
