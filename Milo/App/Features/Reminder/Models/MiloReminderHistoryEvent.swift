//
//  MiloReminderHistoryEvent.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct MiloReminderHistoryEvent: Codable, Identifiable, Equatable {
    let id: UUID
    let reminderID: UUID
    let title: String
    let message: String
    let dueDate: Date
    let status: ReminderStatus
    let createdSource: ReminderCreatedSource
    let createdAt: Date
    let updatedAt: Date
    let eventType: ReminderHistoryEventType
    let eventDate: Date
    let note: String?

    init(
        id: UUID = UUID(),
        reminderID: UUID,
        title: String,
        message: String,
        dueDate: Date,
        status: ReminderStatus,
        createdSource: ReminderCreatedSource,
        createdAt: Date,
        updatedAt: Date,
        eventType: ReminderHistoryEventType,
        eventDate: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.reminderID = reminderID
        self.title = title
        self.message = message
        self.dueDate = dueDate
        self.status = status
        self.createdSource = createdSource
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.eventType = eventType
        self.eventDate = eventDate
        self.note = note
    }
}

enum ReminderHistoryEventType: String, Codable, Equatable {
    case created
    case dueTriggered
    case completed
    case snoozed
    case rescheduled
    case cancelled
    case deleted
}
