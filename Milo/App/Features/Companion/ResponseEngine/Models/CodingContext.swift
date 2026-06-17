//
//  CodingContext.swift
//  Milo
//
//  PRIVACY: CodingContext aggregates safe metadata summaries only.
//  No typed text, source code, clipboard, or private content is stored.
//

import Foundation

struct CodingContext: Equatable {
    let now: Date

    let activeCodingMinutesToday: Int
    let currentFocusMinutes: Int
    let idleMinutes: Int

    let typingIntensity: TypingIntensity
    let activeProjectName: String?
    let activeLanguage: String?
    let activeEditorName: String?

    let todoCount: Int
    let overdueTodoCount: Int
    let reminderDueCount: Int

    let pomodoroState: MiloPomodoroState
    let completedPomodoroCountToday: Int
    let skippedBreakCountToday: Int

    let timeOfDay: TimeOfDay
    let codingStreakDays: Int

    static let empty = CodingContext(
        now: Date(),
        activeCodingMinutesToday: 0,
        currentFocusMinutes: 0,
        idleMinutes: 0,
        typingIntensity: .inactive,
        activeProjectName: nil,
        activeLanguage: nil,
        activeEditorName: nil,
        todoCount: 0,
        overdueTodoCount: 0,
        reminderDueCount: 0,
        pomodoroState: .idle,
        completedPomodoroCountToday: 0,
        skippedBreakCountToday: 0,
        timeOfDay: .unknown,
        codingStreakDays: 0
    )
}

enum MiloPomodoroState: String, Codable, Equatable {
    case idle
    case focusing
    case breakTime
    case paused
}
