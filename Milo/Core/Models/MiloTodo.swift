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
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date
    var priority: TodoPriority
    var linkedReminderID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        priority: TodoPriority = .normal,
        linkedReminderID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.priority = priority
        self.linkedReminderID = linkedReminderID
    }
}

enum TodoPriority: String, Codable {
    case low
    case normal
    case high
}
