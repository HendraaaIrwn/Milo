//
//  UnifiedAgentHookEvent.swift
//  Milo
//
//  PRIVACY: Safe hook metadata only. No prompt text, responses,
//  tool input/output, source code, terminal output, full paths,
//  clipboard contents, passwords, API keys, secrets, or raw JSON.
//

import Foundation

struct UnifiedAgentHookEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let agentType: MiloAgentType
    let eventName: String
    let normalizedEvent: UnifiedAgentEventKind
    let receivedAt: Date

    let sessionHash: String?
    let workspaceName: String?
    let toolName: String?

    let deliveryMethod: AgentEventDeliveryMethod

    init(
        id: UUID = UUID(),
        agentType: MiloAgentType,
        eventName: String,
        normalizedEvent: UnifiedAgentEventKind,
        receivedAt: Date = Date(),
        sessionHash: String? = nil,
        workspaceName: String? = nil,
        toolName: String? = nil,
        deliveryMethod: AgentEventDeliveryMethod
    ) {
        self.id = id
        self.agentType = agentType
        self.eventName = eventName
        self.normalizedEvent = normalizedEvent
        self.receivedAt = receivedAt
        self.sessionHash = sessionHash
        self.workspaceName = workspaceName
        self.toolName = toolName
        self.deliveryMethod = deliveryMethod
    }
}
