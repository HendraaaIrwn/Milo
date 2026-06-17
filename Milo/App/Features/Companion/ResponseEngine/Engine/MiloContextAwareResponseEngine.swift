//
//  MiloContextAwareResponseEngine.swift
//  Milo
//
//  PRIVACY: Uses metadata summaries only. No typed text, source code,
//  clipboard, or private content is inspected or stored.
//

import Foundation

@MainActor
final class MiloContextAwareResponseEngine {
    private let moodDetector = MiloMoodDetector()
    private let intentPlanner = MiloResponseIntentPlanner()
    private let composer = MiloResponseComposer()

    private var history = MiloResponseHistory()
    private var lastResponseAtByEvent: [MiloResponseEvent: Date] = [:]

    private let defaultCooldown: TimeInterval = 8
    private let typingCooldown: TimeInterval = 12
    private let clickCooldown: TimeInterval = 2

    func generateResponse(
        event: MiloResponseEvent,
        context: CodingContext
    ) -> String? {
        guard passesCooldown(event: event) else {
            MiloResponseDebugLogger.log("Rejected — cooldown for \(event.rawValue)")
            return nil
        }

        let mood = moodDetector.detectMood(from: context)
        let intent = intentPlanner.chooseIntent(event: event, context: context, mood: mood)

        MiloResponseDebugLogger.log("Event=\(event.rawValue) Mood=\(mood.rawValue) Intent=\(intent.rawValue) Focus=\(context.currentFocusMinutes)m Today=\(context.activeCodingMinutesToday)m Typing=\(context.typingIntensity.rawValue)")

        guard let result = composer.compose(
            intent: intent,
            mood: mood,
            context: context,
            history: history
        ) else {
            MiloResponseDebugLogger.log("No template matched — using fallback")
            return fallbackResponse(for: event, context: context)
        }

        history.record(templateID: result.templateID, text: result.text, intent: intent)
        lastResponseAtByEvent[event] = Date()

        MiloResponseDebugLogger.log("Selected template=\(result.templateID) text=\"\(result.text)\"")
        return result.text
    }

    var responseMood: MiloResponseMood {
        let context = CodingContext.empty
        return moodDetector.detectMood(from: context)
    }

    private func passesCooldown(event: MiloResponseEvent) -> Bool {
        let now = Date()
        let cooldown: TimeInterval
        switch event {
        case .typingDetected: cooldown = typingCooldown
        case .miloClicked:    cooldown = clickCooldown
        default:              cooldown = defaultCooldown
        }
        if let last = lastResponseAtByEvent[event],
           now.timeIntervalSince(last) < cooldown {
            return false
        }
        return true
    }

    private func fallbackResponse(
        for event: MiloResponseEvent,
        context: CodingContext
    ) -> String? {
        switch event {
        case .miloClicked:
            return MiloReactionLineProvider.randomLine()
        case .typingDetected:
            return "Keyboard activity detected. Very dramatic."
        case .returnedFromIdle:
            return "Welcome back."
        case .todoAdded:
            return "Todo saved."
        case .reminderDue:
            return "Reminder time."
        case .pomodoroCompleted:
            return "Pomodoro complete."
        case .breakSkipped:
            return "Break skipped. I saw that."
        case .dailyMilestone:
            return "\(context.activeCodingMinutesToday) minutes today. Nice."
        case .lateNightCoding:
            return "Late-night coding detected."
        case .system:
            return nil
        }
    }
}
