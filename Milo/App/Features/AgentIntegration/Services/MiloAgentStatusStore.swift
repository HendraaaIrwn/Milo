//
//  MiloAgentStatusStore.swift
//  Milo
//

import Foundation
import Combine

@MainActor
final class MiloAgentStatusStore: ObservableObject {
    @Published private(set) var currentEvent: MiloAgentEvent?
    @Published private(set) var currentState: MiloAgentState = .idle
    @Published private(set) var activeAgentType: MiloAgentType = .unknown
    private(set) var history = MiloAgentEventHistory()

    func update(_ event: MiloAgentEvent) {
        guard currentState != event.state
                || activeAgentType != event.agentType
                || currentEvent?.title != event.title else { return }

        currentEvent = event
        currentState = event.state
        activeAgentType = event.agentType

        let isTransition = event.state == .done
            || event.state == .failed
            || event.state == .needsReview
            || event.state == .waitingForUserInput

        if isTransition { history.record(event) }
    }

    func clear() {
        guard currentState != .idle || activeAgentType != .unknown || currentEvent != nil else { return }
        currentEvent = nil
        currentState = .idle
        activeAgentType = .unknown
    }

    func clearHistory() { history.clear() }
}
