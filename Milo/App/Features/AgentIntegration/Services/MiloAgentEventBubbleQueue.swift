//
//  MiloAgentEventBubbleQueue.swift
//  Milo
//

import Foundation

@MainActor
final class MiloAgentEventBubbleQueue {
    private struct QueuedBubble: Identifiable {
        let id = UUID()
        let text: String
        let priority: MiloBubblePriority
        let source: MiloBubbleSource
    }

    private var queue: [QueuedBubble] = []
    private var isDraining = false
    private var overflowCount = 0
    private var lastShownAt: Date?
    private var drainTask: Task<Void, Never>?

    private weak var overlayCoordinator: MiloOverlayCoordinator?

    init(overlayCoordinator: MiloOverlayCoordinator) {
        self.overlayCoordinator = overlayCoordinator
    }

    func enqueue(text: String, priority: MiloBubblePriority, source: MiloBubbleSource) {
        let item = QueuedBubble(text: text, priority: priority, source: source)
        if queue.count >= 12 {
            if priority == .high {
                queue.insert(item, at: 0)
            } else {
                overflowCount += 1
            }
        } else if priority == .high {
            queue.insert(item, at: 0)
        } else {
            queue.append(item)
        }
        drainIfNeeded()
    }

    func enqueueTestSuccess(agentType: MiloAgentType) {
        enqueue(
            text: "\(agentType == .codex ? "Codex" : "Claude") hook test received. Tiny bridge online.",
            priority: .high,
            source: .agent
        )
    }

    func enqueueTestFailure(agentType: MiloAgentType) {
        enqueue(
            text: "MILO could not receive the \(agentType == .codex ? "Codex" : "Claude") hook test.",
            priority: .high,
            source: .agent
        )
    }

    func clear() {
        drainTask?.cancel()
        drainTask = nil
        queue.removeAll()
        overflowCount = 0
        isDraining = false
    }

    private func drainIfNeeded() {
        guard !isDraining else { return }
        isDraining = true
        drainTask = Task { @MainActor [weak self] in
            await self?.drainLoop()
        }
    }

    private func drainLoop() async {
        while !queue.isEmpty || overflowCount > 0 {
            if !queue.isEmpty {
                let item = queue.removeFirst()
                await waitForGap()
                overlayCoordinator?.showBubble(
                    text: item.text,
                    source: item.source,
                    priority: item.priority,
                    duration: defaultDuration(for: item.priority)
                )
                lastShownAt = Date()
            } else if overflowCount > 0 {
                let count = overflowCount
                overflowCount = 0
                await waitForGap()
                overlayCoordinator?.showBubble(
                    text: "Agent had \(count) more tiny events.",
                    source: .agent,
                    priority: .low,
                    duration: 3
                )
                lastShownAt = Date()
            }
        }
        isDraining = false
    }

    private func waitForGap() async {
        guard let lastShownAt else { return }
        let elapsed = Date().timeIntervalSince(lastShownAt)
        guard elapsed < 0.75 else { return }
        try? await Task.sleep(nanoseconds: UInt64((0.75 - elapsed) * 1_000_000_000))
    }

    private func defaultDuration(for priority: MiloBubblePriority) -> TimeInterval {
        switch priority {
        case .critical: return 5
        case .high:     return 4
        case .normal:   return 3
        case .low:      return 2.5
        }
    }
}
