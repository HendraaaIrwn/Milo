//
//  MiloBubbleCoordinator.swift
//  Milo
//
//  Central coordinator for all bubble events.
//  Handles priority, cooldown, and token-based hide timers
//  so old timers can never close new bubbles.
//

import AppKit
import Foundation

@MainActor
final class MiloBubbleCoordinator {
    private let bubbleWindowController: MiloBubbleWindowController

    private var currentRequest: MiloBubbleRequest?
    private var currentRequestID: UUID?
    private var hideTask: Task<Void, Never>?

    private var latestCharacterFrame: NSRect = .zero

    private var lastTypingBubbleAt: Date?
    private var lastLowPriorityBubbleAt: Date?

    private let typingCooldown: TimeInterval = 8
    private let lowPriorityCooldown: TimeInterval = 6

    init(bubbleWindowController: MiloBubbleWindowController) {
        self.bubbleWindowController = bubbleWindowController
    }

    func configureWindow() {
        bubbleWindowController.configure()
    }

    func updateCharacterFrame(_ frame: NSRect) {
        latestCharacterFrame = frame

        if bubbleWindowController.isVisible {
            bubbleWindowController.updatePosition(relativeTo: frame)
        }
    }

    func show(_ request: MiloBubbleRequest) {
        guard shouldAccept(request) else {
            print("[BubbleCoordinator] rejected: \(request.source) priority=\(request.priority)")
            return
        }

        print("[BubbleCoordinator] accepted: \(request.source) priority=\(request.priority) id=\(request.id)")
        replaceCurrentBubble(with: request)
    }

    func show(
        text: String,
        source: MiloBubbleSource,
        priority: MiloBubblePriority? = nil,
        duration: TimeInterval? = nil
    ) {
        let request = MiloBubbleRequest(
            text: text,
            source: source,
            priority: priority,
            duration: duration
        )
        show(request)
    }

    func hideCurrentBubble() {
        hideTask?.cancel()
        hideTask = nil
        currentRequest = nil
        currentRequestID = nil
        bubbleWindowController.hide()
    }

    func destroy() {
        hideCurrentBubble()
        bubbleWindowController.destroy()
    }

    // MARK: - Internal

    private func shouldAccept(_ newRequest: MiloBubbleRequest) -> Bool {
        let now = Date()

        if newRequest.source == .typing {
            if let last = lastTypingBubbleAt,
               now.timeIntervalSince(last) < typingCooldown {
                return false
            }
            lastTypingBubbleAt = now
        }

        if newRequest.priority == .low {
            if let last = lastLowPriorityBubbleAt,
               now.timeIntervalSince(last) < lowPriorityCooldown {
                return false
            }
            lastLowPriorityBubbleAt = now
        }

        guard let currentRequest else {
            return true
        }

        if newRequest.priority < currentRequest.priority {
            return false
        }

        return true
    }

    private func replaceCurrentBubble(with request: MiloBubbleRequest) {
        currentRequest = request
        currentRequestID = request.id

        hideTask?.cancel()
        hideTask = nil

        bubbleWindowController.show(
            text: request.text,
            relativeTo: latestCharacterFrame
        )

        MiloMumbleEngine.shared.speak(request.text)

        scheduleHide(for: request)
    }

    private func scheduleHide(for request: MiloBubbleRequest) {
        let requestID = request.id

        hideTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(request.duration * 1_000_000_000))

            await MainActor.run {
                guard let self else { return }

                guard self.currentRequestID == requestID else {
                    print("[BubbleCoordinator] hide ignored — stale token \(requestID)")
                    return
                }

                print("[BubbleCoordinator] hide fired: \(request.source) id=\(requestID)")
                self.bubbleWindowController.hide()
                self.currentRequest = nil
                self.currentRequestID = nil
                self.hideTask = nil
            }
        }
    }
}
