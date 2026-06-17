//
//  MiloSmartPersonalityInput.swift
//  Milo
//
//  PRIVACY: This struct carries only sanitized coding metadata.
//  Typed text, source code, clipboard, and private content are NEVER included.
//

import Foundation

struct MiloSmartPersonalityInput: Codable, Equatable {
    let event: MiloResponseEvent
    let intent: MiloResponseIntent
    let mood: MiloResponseMood

    let localCandidate: String?

    let focusMinutes: Int?
    let todayMinutes: Int?
    let idleMinutes: Int?

    let typingIntensity: String?

    let activeProjectName: String?
    let activeLanguage: String?
    let activeEditorName: String?

    let todoCount: Int?
    let overdueTodoCount: Int?
    let reminderDueCount: Int?

    let pomodoroState: String?
    let completedPomodoroCountToday: Int?
    let skippedBreakCountToday: Int?

    let timeOfDay: String?
    let codingStreakDays: Int?

    let tone: MiloPersonalityTone
    let maxWords: Int
    let allowPlayfulRoast: Bool
}
