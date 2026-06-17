//
//  MiloResponseIntentPlanner.swift
//  Milo
//

import Foundation

struct MiloResponseIntentPlanner {
    func chooseIntent(
        event: MiloResponseEvent,
        context: CodingContext,
        mood: MiloResponseMood
    ) -> MiloResponseIntent {
        switch event {
        case .miloClicked:
            if context.currentFocusMinutes >= 90 {
                return .suggestBreak
            }
            if context.typingIntensity == .fast {
                return .lightRoast
            }
            if let language = context.activeLanguage, !language.isEmpty {
                return .languageComment
            }
            return .encourage

        case .typingDetected:
            if context.currentFocusMinutes >= 60 {
                return .focusReminder
            }
            return .typingReaction

        case .returnedFromIdle:
            return .welcomeBack

        case .todoAdded:
            return .todoReminder

        case .reminderDue:
            return .reminderDue

        case .pomodoroCompleted:
            return .pomodoroComplete

        case .breakSkipped:
            return .suggestBreak

        case .dailyMilestone:
            return .celebrateProgress

        case .lateNightCoding:
            return .lateNightCheck

        case .system:
            return .system
        }
    }
}
