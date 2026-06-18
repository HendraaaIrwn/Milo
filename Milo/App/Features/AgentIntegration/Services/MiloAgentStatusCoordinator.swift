//
//  MiloAgentStatusCoordinator.swift
//  Milo
//
//  PRIVACY: Routes agent events to badge display, bubbles, and optional sound.
//  Only uses sanitized MiloAgentEvent data — never accesses process logs or terminal content.
//  Deduplicates events to prevent repeated badge/bubble updates.
//

import Foundation
import Combine

@MainActor
final class MiloAgentStatusCoordinator {
    private let statusStore: MiloAgentStatusStore
    private let settingsStore: MiloAgentDetectionSettingsStore
    private let overlayCoordinator: MiloOverlayCoordinator
    private let reactionMapper = MiloAgentReactionMapper()

    private var lastHandledSnapshot: HandledAgentSnapshot = .idle
    private var lastBadgeEventId: UUID?
    private var cancellables = Set<AnyCancellable>()

    init(
        statusStore: MiloAgentStatusStore,
        settingsStore: MiloAgentDetectionSettingsStore,
        overlayCoordinator: MiloOverlayCoordinator
    ) {
        self.statusStore = statusStore
        self.settingsStore = settingsStore
        self.overlayCoordinator = overlayCoordinator
        observe()
    }

    private func observe() {
        statusStore.$currentEvent
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                Task { @MainActor [weak self] in self?.handle(event) }
            }
            .store(in: &cancellables)
    }

    private func handle(_ event: MiloAgentEvent?) {
        let snapshot = HandledAgentSnapshot(event)

        guard let event else {
            overlayCoordinator.hideAgentStatusBadge()
            lastHandledSnapshot = .idle
            lastBadgeEventId = nil
            return
        }

        // Show badge first so it appears for .running/.thinking states.
        // Re-show only when the event identity changes, not on identical snapshots,
        // to avoid repositioning churn while a build is running.
        if settingsStore.settings.showFloatingBadge,
           lastBadgeEventId != event.id {
            overlayCoordinator.showAgentStatusBadge(event)
            lastBadgeEventId = event.id
        }

        guard snapshot != lastHandledSnapshot else { return }
        lastHandledSnapshot = snapshot

        if MiloMenuInteractionState.shared.isMenuTracking {
            return
        }

        switch event.state {
        case .idle:
            overlayCoordinator.hideAgentStatusBadge()
            lastBadgeEventId = nil

        case .running, .thinking:
            // Badge only. Do not show bubble to prevent spam.
            break

        case .waitingForUserInput:
            if let text = reactionMapper.bubbleText(for: event) {
                overlayCoordinator.showBubble(text: text, source: .agent, priority: .normal, duration: 4)
            }

        case .done:
            if settingsStore.settings.notifyOnDone,
               let text = reactionMapper.bubbleText(for: event) {
                overlayCoordinator.showBubble(text: text, source: .agent, priority: .high, duration: 4)
            }

        case .failed:
            if settingsStore.settings.notifyOnFailed,
               let text = reactionMapper.bubbleText(for: event) {
                overlayCoordinator.showBubble(text: text, source: .agent, priority: .high, duration: 5)
            }

        case .needsReview:
            if let text = reactionMapper.bubbleText(for: event) {
                overlayCoordinator.showBubble(text: text, source: .agent, priority: .high, duration: 6)
            }
        }
    }
}

private struct HandledAgentSnapshot: Equatable {
    let state: MiloAgentState
    let agentType: MiloAgentType
    let title: String
    static let idle = HandledAgentSnapshot(state: .idle, agentType: .unknown, title: "")
    init(state: MiloAgentState, agentType: MiloAgentType, title: String) {
        self.state = state; self.agentType = agentType; self.title = title
    }
    init(_ event: MiloAgentEvent?) {
        self.state = event?.state ?? .idle
        self.agentType = event?.agentType ?? .unknown
        self.title = event?.title ?? ""
    }
}