//
//  MiloClaudeEventBubbleQueue.swift
//  Milo
//
//  PRIVACY: Holds only reaction copy text and bubble priority — never
//  raw event payloads. Drains into the existing MiloBubbleCoordinator
//  (via overlayCoordinator.showBubble) so the platform bubble rules
//  (priority, cooldown, single bubble) still apply.
//
//  Behavior:
//   - One bubble at a time.
//   - Minimum 0.75s between event bubbles.
//   - If pending count exceeds 12, overflow events are aggregated into
//     a single "Claude had N more tiny events." bubble with low priority.
//   - High-priority events (Notification, Stop, SessionEnd) jump the
//     FIFO and are never aggregated.
//

import Foundation
import Combine

@MainActor
final class MiloClaudeEventBubbleQueue {
    private struct Pending {
        let text: String
        let priority: MiloBubblePriority
    }

    private weak var overlayCoordinator: MiloOverlayCoordinator?
    private let mapper = MiloClaudeReactionMapper()
    private let showBubble: (String, MiloBubbleSource, MiloBubblePriority, TimeInterval) -> Void

    private var pending: [Pending] = []
    private var overflowCount: Int = 0
    private var draining: Bool = false
    private var lastShownAt: Date?
    private var drainTask: Task<Void, Never>?

    init(overlayCoordinator: MiloOverlayCoordinator) {
        self.overlayCoordinator = overlayCoordinator
        // Capture a stable closure so we can call into the bubble coordinator
        // without holding a strong reference to the overlay coordinator.
        self.showBubble = { [weak overlayCoordinator] text, source, priority, duration in
            overlayCoordinator?.showBubble(
                text: text,
                source: source,
                priority: priority,
                duration: duration
            )
        }
    }

    func enqueue(_ event: MiloClaudeHookEvent) {
        guard let text = mapper.bubbleText(for: event) else { return }
        let priority = mapper.priority(for: event)

        if pending.count >= MiloClaudeEventBubbleQueueConfig.maxQueueSize {
            // Aggregation rule: collapse low/normal overflow into a count
            // bubble. High-priority events always go through (they are
            // never aggregated).
            if priority == .high {
                pending.append(Pending(text: text, priority: priority))
                scheduleDrain()
                return
            }
            overflowCount += 1
            scheduleDrain()
            return
        }

        pending.append(Pending(text: text, priority: priority))
        scheduleDrain()
    }

    func enqueueTestSuccess() {
        pending.append(Pending(
            text: "Claude hook test received. Tiny bridge online.",
            priority: .high
        ))
        scheduleDrain()
    }

    func enqueueTestFailure() {
        pending.append(Pending(
            text: "MILO could not receive the Claude hook test.",
            priority: .high
        ))
        scheduleDrain()
    }

    func clear() {
        drainTask?.cancel()
        drainTask = nil
        pending.removeAll()
        overflowCount = 0
        draining = false
    }

    private func scheduleDrain() {
        guard !draining else { return }
        draining = true
        drainTask = Task { @MainActor [weak self] in
            await self?.drainLoop()
        }
    }

    private func drainLoop() async {
        while !pending.isEmpty || overflowCount > 0 {
            // High-priority events jump the FIFO.
            let nextIndex = pending.firstIndex(where: { $0.priority == .high }) ?? 0
            let next = pending.remove(at: nextIndex)

            if let last = lastShownAt {
                let elapsed = Date().timeIntervalSince(last)
                if elapsed < MiloClaudeEventBubbleQueueConfig.minimumGapSeconds {
                    let wait = MiloClaudeEventBubbleQueueConfig.minimumGapSeconds - elapsed
                    try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                }
            }

            showBubble(next.text, .agent, next.priority, defaultDuration(for: next.priority))
            lastShownAt = Date()
        }

        if overflowCount > 0 {
            if let last = lastShownAt {
                let elapsed = Date().timeIntervalSince(last)
                if elapsed < MiloClaudeEventBubbleQueueConfig.minimumGapSeconds {
                    let wait = MiloClaudeEventBubbleQueueConfig.minimumGapSeconds - elapsed
                    try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                }
            }
            let count = overflowCount
            overflowCount = 0
            showBubble(
                "Claude had \(count) more tiny events.",
                .agent,
                .low,
                3
            )
            lastShownAt = Date()
        }

        draining = false
    }

    private func defaultDuration(for priority: MiloBubblePriority) -> TimeInterval {
        switch priority {
        case .high:     return 4
        case .normal:   return 3
        case .low:      return 2.5
        case .critical: return 5
        }
    }
}
