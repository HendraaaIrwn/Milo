//
//  TypingBubbleService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

/// PRIVACY:
/// MILO does not know what the user is typing.
/// Typing bubble lines are generated only from typing intensity and timing.
/// No typed characters, code, clipboard, or key history are read or stored.
@MainActor
final class TypingBubbleService {
    private weak var miloStateStore: MiloStateStore?

    private var hideBubbleTask: Task<Void, Never>?
    private var cooldownTask: Task<Void, Never>?

    private var canShowBubble = true
    private let bubbleVisibleNanoseconds: UInt64 = 3_000_000_000

    init(miloStateStore: MiloStateStore) {
        self.miloStateStore = miloStateStore
    }

    func handleTypingActivity(intensity: TypingIntensity) {
        guard UserDefaults.standard.object(forKey: MiloSettingsKeys.typingBubbleDialogs) as? Bool ?? true else { return }
        guard let miloStateStore else { return }
        guard miloStateStore.isTyping else { return }
        guard canShowBubble else { return }

        let typingDuration = Date().timeIntervalSince(miloStateStore.typingStartedAt ?? Date())
        guard typingDuration >= 1.0 else { return }

        showBubble(for: intensity)
    }

    func handleTypingStopped() {
        hideBubbleTask?.cancel()
        cooldownTask?.cancel()
        hideBubbleTask = nil
        cooldownTask = nil

        canShowBubble = true
        miloStateStore?.hideTypingBubble()
    }

    func handleTypingBubbleDisabled() {
        hideBubbleTask?.cancel()
        hideBubbleTask = nil
        miloStateStore?.hideTypingBubble()
    }

    private func showBubble(for intensity: TypingIntensity) {
        guard let miloStateStore else { return }

        canShowBubble = false
        miloStateStore.showTypingBubble(MiloTypingDialogProvider.randomLine(for: intensity))

        scheduleBubbleHide()
        scheduleCooldown(for: intensity)
    }

    private func scheduleBubbleHide() {
        hideBubbleTask?.cancel()

        hideBubbleTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.bubbleVisibleNanoseconds ?? 3_000_000_000)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.miloStateStore?.hideTypingBubble()
            }
        }
    }

    private func scheduleCooldown(for intensity: TypingIntensity) {
        cooldownTask?.cancel()

        let cooldownSeconds: UInt64 = switch intensity {
        case .inactive: 10
        case .slow: 12
        case .normal: 10
        case .fast: 8
        }

        cooldownTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: cooldownSeconds * 1_000_000_000)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.canShowBubble = true
            }
        }
    }

    deinit {
        hideBubbleTask?.cancel()
        cooldownTask?.cancel()
    }
}
