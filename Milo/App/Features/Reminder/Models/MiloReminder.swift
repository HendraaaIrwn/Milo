//
//  MiloReminder.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct MiloReminder: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var message: String
    var dueDate: Date
    var repeatRule: ReminderRepeatRule?
    var soundMode: ReminderSoundMode
    var status: ReminderStatus
    var isCompleted: Bool
    var createdSource: ReminderCreatedSource
    var localNotificationID: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        dueDate: Date,
        repeatRule: ReminderRepeatRule? = nil,
        soundMode: ReminderSoundMode = .mumble,
        status: ReminderStatus = .pending,
        isCompleted: Bool = false,
        createdSource: ReminderCreatedSource,
        localNotificationID: String = UUID().uuidString,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.dueDate = dueDate
        self.repeatRule = repeatRule
        self.soundMode = soundMode
        self.status = status
        self.isCompleted = isCompleted
        self.createdSource = createdSource
        self.localNotificationID = localNotificationID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(
        id: UUID = UUID(),
        message: String,
        dueDate: Date,
        isDone: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        source: ReminderCreatedSource = .rightClick,
        soundMode: ReminderSoundMode = .mumble,
        repeatRule: ReminderRepeatRule? = nil
    ) {
        self.init(
            id: id,
            title: message,
            message: message,
            dueDate: dueDate,
            repeatRule: repeatRule,
            soundMode: soundMode,
            status: isDone ? .completed : .pending,
            isCompleted: isDone,
            createdSource: source,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case dueDate
        case repeatRule
        case soundMode
        case status
        case isCompleted
        case isDone
        case createdSource
        case source
        case localNotificationID
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        message = try container.decode(String.self, forKey: .message)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? message
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        repeatRule = try container.decodeIfPresent(ReminderRepeatRule.self, forKey: .repeatRule)
        soundMode = try container.decodeIfPresent(ReminderSoundMode.self, forKey: .soundMode) ?? .mumble
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted)
            ?? container.decodeIfPresent(Bool.self, forKey: .isDone)
            ?? false
        status = try container.decodeIfPresent(ReminderStatus.self, forKey: .status)
            ?? (isCompleted ? .completed : .pending)
        createdSource = try container.decodeIfPresent(ReminderCreatedSource.self, forKey: .createdSource)
            ?? container.decodeIfPresent(ReminderCreatedSource.self, forKey: .source)
            ?? .rightClick
        localNotificationID = try container.decodeIfPresent(String.self, forKey: .localNotificationID) ?? UUID().uuidString
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(repeatRule, forKey: .repeatRule)
        try container.encode(soundMode, forKey: .soundMode)
        try container.encode(status, forKey: .status)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(createdSource, forKey: .createdSource)
        try container.encode(localNotificationID, forKey: .localNotificationID)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

enum ReminderStatus: String, Codable, Equatable {
    case pending
    case due
    case completed
    case snoozed
    case rescheduled
    case cancelled
}

enum ReminderRepeatRule: String, Codable, Equatable {
    case once
    case daily
    case weekdays
    case weekly
}

enum ReminderSoundMode: String, Codable, Equatable {
    case silent
    case meow
    case mumble
    case reminderBell
    case softPing
    case urgent

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "silent": self = .silent
        case "meow", "softPing": self = .meow
        case "mumble": self = .mumble
        case "urgent", "reminderBell": self = .reminderBell
        default: self = .mumble
        }
    }
}

enum ReminderCreatedSource: String, Codable, Equatable {
    case rightClick
    case chat
    case todo
    case pomodoro
    case menuBar
    case manual
    case system

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "chat": self = .chat
        case "todo": self = .todo
        case "pomodoro": self = .pomodoro
        case "menuBar": self = .menuBar
        case "manual", "rightClick", "system": self = .rightClick
        default: self = .rightClick
        }
    }
}

typealias ReminderSource = ReminderCreatedSource
