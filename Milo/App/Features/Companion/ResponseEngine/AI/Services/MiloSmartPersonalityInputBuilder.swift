//
//  MiloSmartPersonalityInputBuilder.swift
//  Milo
//
//  PRIVACY: Builds sanitized input respecting user privacy settings.
//  project name is hidden when allowProjectName is false.
//

import Foundation

struct MiloSmartPersonalityInputBuilder {
    func build(
        event: MiloResponseEvent,
        intent: MiloResponseIntent,
        mood: MiloResponseMood,
        context: CodingContext,
        localCandidate: String?,
        settings: MiloPersonalitySettings
    ) -> MiloSmartPersonalityInput {
        MiloSmartPersonalityInput(
            event: event,
            intent: intent,
            mood: mood,
            localCandidate: localCandidate,

            focusMinutes: settings.allowCodingDuration ? context.currentFocusMinutes : nil,
            todayMinutes: settings.allowCodingDuration ? context.activeCodingMinutesToday : nil,
            idleMinutes: context.idleMinutes,

            typingIntensity: settings.allowTypingIntensity ? context.typingIntensity.rawValue : nil,

            activeProjectName: settings.allowProjectName ? context.activeProjectName : "current project",
            activeLanguage: settings.allowActiveLanguage ? context.activeLanguage : nil,
            activeEditorName: context.activeEditorName,

            todoCount: settings.allowTodoCounts ? context.todoCount : nil,
            overdueTodoCount: settings.allowTodoCounts ? context.overdueTodoCount : nil,
            reminderDueCount: settings.allowTodoCounts ? context.reminderDueCount : nil,

            pomodoroState: settings.allowPomodoroState ? context.pomodoroState.rawValue : nil,
            completedPomodoroCountToday: settings.allowPomodoroState ? context.completedPomodoroCountToday : nil,
            skippedBreakCountToday: settings.allowPomodoroState ? context.skippedBreakCountToday : nil,

            timeOfDay: context.timeOfDay.rawValue,
            codingStreakDays: context.codingStreakDays,

            tone: settings.tone,
            maxWords: settings.maxResponseWords,
            allowPlayfulRoast: settings.allowPlayfulRoast
        )
    }
}
