//
//  MiloReminder.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct MiloReminder: Codable, Identifiable, Equatable {
    let id: UUID
    var message: String
    var dueDate: Date
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date
    var source: ReminderSource
    var soundMode: ReminderSoundMode
    var repeatRule: ReminderRepeatRule?

    init(
        id: UUID = UUID(),
        message: String,
        dueDate: Date,
        isDone: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        source: ReminderSource = .manual,
        soundMode: ReminderSoundMode = .reminderBell,
        repeatRule: ReminderRepeatRule? = nil
    ) {
        self.id = id
        self.message = message
        self.dueDate = dueDate
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
        self.soundMode = soundMode
        self.repeatRule = repeatRule
    }
}

enum ReminderSource: String, Codable {
    case manual
    case menuBar
    case rightClick
    case chat
    case todo
    case pomodoro
    case system
}

enum ReminderSoundMode: String, Codable {
    case silent
    case reminderBell
    case softPing
    case meow
    case mumble
    case urgent
}

enum ReminderRepeatRule: String, Codable {
    case once
    case daily
    case weekdays
}
