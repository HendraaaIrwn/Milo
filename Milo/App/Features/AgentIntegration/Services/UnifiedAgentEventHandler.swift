//
//  UnifiedAgentEventHandler.swift
//  Milo
//

import Foundation
import Combine

@MainActor
final class UnifiedAgentEventHandler: ObservableObject {
    private let statusStore: MiloAgentStatusStore
    private let overlayCoordinator: MiloOverlayCoordinator
    private let bubbleQueue: MiloAgentEventBubbleQueue
    private let petState: MiloFloatingPetState
    private let mapper = UnifiedAgentEventMapper()

    @Published private(set) var lastReceivedEvent: UnifiedAgentHookEvent?

    init(
        statusStore: MiloAgentStatusStore,
        overlayCoordinator: MiloOverlayCoordinator,
        bubbleQueue: MiloAgentEventBubbleQueue,
        petState: MiloFloatingPetState
    ) {
        self.statusStore = statusStore
        self.overlayCoordinator = overlayCoordinator
        self.bubbleQueue = bubbleQueue
        self.petState = petState
    }

    func handle(_ event: UnifiedAgentHookEvent) {
        lastReceivedEvent = event
        let agentEvent = mapToAgentEvent(event)
        statusStore.update(agentEvent)
        overlayCoordinator.showAgentStatusBadge(agentEvent)
        bubbleQueue.enqueue(
            text: mapper.bubbleText(for: event),
            priority: mapper.priority(for: event),
            source: .agent
        )
        petState.mood = mapper.companionMood(for: event)
    }

    private func mapToAgentEvent(_ event: UnifiedAgentHookEvent) -> MiloAgentEvent {
        MiloAgentEvent(
            agentType: event.agentType,
            state: mapper.agentState(for: event),
            title: mapper.badgeLabel(for: event),
            detail: event.toolName.map { "Tool: \($0)" }
        )
    }
}
