//
//  MiloTodo.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct MiloTodo: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var dueDate: Date?
    var status: TodoStatus
    var createdSource: TodoCreatedSource
    var priority: TodoPriority
    var linkedReminderID: UUID?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        status: TodoStatus = .active,
        priority: TodoPriority = .normal,
        createdSource: TodoCreatedSource = .chat,
        linkedReminderID: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.status = status
        self.priority = priority
        self.createdSource = createdSource
        self.linkedReminderID = linkedReminderID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, notes, dueDate, status, createdSource, priority, linkedReminderID
        case createdAt, updatedAt, isDone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        priority = try container.decodeIfPresent(TodoPriority.self, forKey: .priority) ?? .normal
        createdSource = try container.decodeIfPresent(TodoCreatedSource.self, forKey: .createdSource) ?? .chat
        linkedReminderID = try container.decodeIfPresent(UUID.self, forKey: .linkedReminderID)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)

        if let status = try container.decodeIfPresent(TodoStatus.self, forKey: .status) {
            self.status = status
        } else {
            let wasDone = try container.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
            self.status = wasDone ? .done : .active
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(status, forKey: .status)
        try container.encode(createdSource, forKey: .createdSource)
        try container.encode(priority, forKey: .priority)
        try container.encodeIfPresent(linkedReminderID, forKey: .linkedReminderID)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

enum TodoStatus: String, Codable, Equatable {
    case active
    case done
    case overdue
    case deleted
}

enum TodoPriority: String, Codable, Equatable {
    case low
    case normal
    case high
}

enum TodoCreatedSource: String, Codable, Equatable {
    case rightClick
    case chat
    case menuBar
    case reminder
    case pomodoro
}
