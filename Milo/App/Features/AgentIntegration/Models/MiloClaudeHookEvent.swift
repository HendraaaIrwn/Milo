//
//  MiloClaudeHookEvent.swift
//  Milo
//
//  PRIVACY: This is the only data shape that crosses the miloctl ↔ MILO
//  boundary. It never carries prompts, responses, tool input/output,
//  source code, terminal output, full file paths, clipboard, secrets,
//  or raw JSON payloads. Adding a new field requires updating the
//  ClaudeHookPayloadSanitizer allowlist and the privacy audit in CLAUDE.md.
//

import Foundation

struct MiloClaudeHookEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let source: String
    let agentType: MiloAgentType
    let eventName: ClaudeHookEventName
    let rawEventName: String
    let receivedAt: Date

    let sessionHash: String?
    let workspaceName: String?
    let toolName: String?

    let deliveryMethod: ClaudeHookDeliveryMethod

    init(
        id: UUID = UUID(),
        source: String = "claude-code",
        agentType: MiloAgentType = .claudeCode,
        eventName: ClaudeHookEventName,
        rawEventName: String,
        receivedAt: Date = Date(),
        sessionHash: String? = nil,
        workspaceName: String? = nil,
        toolName: String? = nil,
        deliveryMethod: ClaudeHookDeliveryMethod
    ) {
        self.id = id
        self.source = source
        self.agentType = agentType
        self.eventName = eventName
        self.rawEventName = rawEventName
        self.receivedAt = receivedAt
        self.sessionHash = sessionHash
        self.workspaceName = workspaceName
        self.toolName = toolName
        self.deliveryMethod = deliveryMethod
    }
}
