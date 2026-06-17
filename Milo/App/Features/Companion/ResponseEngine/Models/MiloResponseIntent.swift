//
//  MiloResponseIntent.swift
//  Milo
//

import Foundation

enum MiloResponseIntent: String, Codable, Equatable {
    case greet
    case encourage
    case lightRoast
    case suggestBreak
    case celebrateProgress
    case welcomeBack
    case focusReminder
    case todoReminder
    case reminderDue
    case pomodoroComplete
    case lateNightCheck
    case typingReaction
    case idleNudge
    case projectComment
    case languageComment
    case system
}
