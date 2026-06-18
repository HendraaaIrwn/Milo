//
//  MiloAgentEventHistory.swift
//  Milo
//
//  PRIVACY: Stores only sanitized event summaries.
//  Never stores raw process commands, terminal output, or private content.
//

import Foundation

struct MiloAgentEventHistory: Codable, Equatable {
    private(set) var events: [MiloAgentEvent] = []

    mutating func record(_ event: MiloAgentEvent) {
        events.insert(event, at: 0)
        events = Array(events.prefix(50))
    }

    mutating func clear() {
        events.removeAll()
    }
}
