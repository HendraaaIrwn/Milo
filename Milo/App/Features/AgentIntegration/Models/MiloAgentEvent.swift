//
//  MiloAgentEvent.swift
//  Milo
//
//  PRIVACY: Only stores safe metadata — agent type, state, timestamps, exit code, changed file count.
//  Never stores raw process commands, terminal output, or private content.
//

import Foundation

struct MiloAgentEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let agentType: MiloAgentType
    let state: MiloAgentState
    let title: String
    let detail: String?
    let startedAt: Date?
    let endedAt: Date?
    let durationSeconds: TimeInterval?
    let exitCode: Int?
    let changedFileCount: Int?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        agentType: MiloAgentType,
        state: MiloAgentState,
        title: String,
        detail: String? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        durationSeconds: TimeInterval? = nil,
        exitCode: Int? = nil,
        changedFileCount: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.agentType = agentType
        self.state = state
        self.title = title
        self.detail = detail
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.exitCode = exitCode
        self.changedFileCount = changedFileCount
        self.createdAt = createdAt
    }
}
