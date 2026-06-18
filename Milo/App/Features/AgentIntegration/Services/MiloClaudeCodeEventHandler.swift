//
//  MiloClaudeCodeEventHandler.swift
//  Milo
//
//  Receives a sanitized MiloClaudeHookEvent and applies it to the
//  existing agent status, overlay, bubble, and mood systems.
//  No raw payload reaches this type — only fields from the
//  allowlist in ClaudeHookPayloadSanitizer.
//

import Foundation
import Combine

@MainActor
final class MiloClaudeCodeEventHandler {
    private let statusStore: MiloAgentStatusStore
    private let overlayCoordinator: MiloOverlayCoordinator
    private let bubbleQueue: MiloClaudeEventBubbleQueue
    private let petState: MiloFloatingPetState
    private let mapper = MiloClaudeReactionMapper()

    @Published private(set) var lastReceivedEvent: MiloClaudeHookEvent?

    init(
        statusStore: MiloAgentStatusStore,
        overlayCoordinator: MiloOverlayCoordinator,
        bubbleQueue: MiloClaudeEventBubbleQueue,
        petState: MiloFloatingPetState
    ) {
        self.statusStore = statusStore
        self.overlayCoordinator = overlayCoordinator
        self.bubbleQueue = bubbleQueue
        self.petState = petState
    }

    func handle(_ event: MiloClaudeHookEvent) {
        lastReceivedEvent = event

        let agentEvent = MiloAgentEvent(
            agentType: event.agentType,
            state: mapper.agentState(for: event),
            title: mapper.title(for: event),
            detail: mapper.detail(for: event)
        )

        statusStore.update(agentEvent)
        overlayCoordinator.showAgentStatusBadge(agentEvent)

        // Apply mood to the companion (does not block the bubble).
        petState.mood = mapper.companionMood(for: event)

        bubbleQueue.enqueue(event)
    }
}
