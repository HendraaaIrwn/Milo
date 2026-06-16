//
//  MiloBubbleRequest.swift
//  Milo
//

import Foundation

struct MiloBubbleRequest: Identifiable, Equatable {
    let id: UUID
    let text: String
    let source: MiloBubbleSource
    let priority: MiloBubblePriority
    let duration: TimeInterval
    let createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        source: MiloBubbleSource,
        priority: MiloBubblePriority? = nil,
        duration: TimeInterval? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.source = source
        self.priority = priority ?? source.defaultPriority
        self.duration = duration ?? source.defaultDuration
        self.createdAt = createdAt
    }
}
