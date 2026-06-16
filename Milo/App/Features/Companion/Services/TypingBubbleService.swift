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
    private var soundTask: Task<Void, Never>?

    private var canShowBubble = true
    private var activeBubbleID = UUID()
    private let bubbleVisibleNanoseconds: UInt64 = 3_000_000_000

    init(miloStateStore: MiloStateStore) {
        self.miloStateStore = miloStateStore
    }

    func handleTypingActivity(intensity: TypingIntensity) {
        guard UserDefaults.standard.object(forKey: MiloSettingsKeys.typingBubbleDialogs) as? Bool ?? true else { return }
        guard let miloStateStore else { return }
        guard !miloStateStore.isContextMenuOpen else { return }
        guard miloStateStore.isTyping else { return }
        guard canShowBubble else { return }

        let typingDuration = Date().timeIntervalSince(miloStateStore.typingStartedAt ?? Date())
        guard typingDuration >= 1.0 else { return }

        showBubble(for: intensity)
    }

    func handleTypingStopped() {
        hideBubbleTask?.cancel()
        cooldownTask?.cancel()
        soundTask?.cancel()
        hideBubbleTask = nil
        cooldownTask = nil
        soundTask = nil

        canShowBubble = true
        activeBubbleID = UUID()
        guard !(miloStateStore?.isContextMenuOpen ?? false) else { return }
        miloStateStore?.hideTypingBubble()
    }

    func handleTypingBubbleDisabled() {
        hideBubbleTask?.cancel()
        soundTask?.cancel()
        hideBubbleTask = nil
        soundTask = nil
        activeBubbleID = UUID()
        guard !(miloStateStore?.isContextMenuOpen ?? false) else { return }
        miloStateStore?.hideTypingBubble()
    }

    private func showBubble(for intensity: TypingIntensity) {
        guard let miloStateStore else { return }
        guard !miloStateStore.isContextMenuOpen else { return }

        canShowBubble = false
        let line = MiloTypingDialogProvider.randomLine(for: intensity)
        let bubbleID = UUID()
        activeBubbleID = bubbleID

        miloStateStore.showTypingBubble(line)
        scheduleBubbleSound(line: line, bubbleID: bubbleID)

        scheduleBubbleHide()
        scheduleCooldown(for: intensity)
    }

    private func scheduleBubbleSound(line: String, bubbleID: UUID) {
        soundTask?.cancel()

        soundTask = Task { [weak self] in
            await Task.yield()
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let self, let miloStateStore = self.miloStateStore else { return }
                guard !miloStateStore.isContextMenuOpen else { return }
                guard self.activeBubbleID == bubbleID else { return }
                guard miloStateStore.isMiloVisible else { return }
                guard miloStateStore.shouldShowTypingBubble else { return }
                guard miloStateStore.typingBubbleText == line else { return }
                guard !miloStateStore.shouldShowReminderBubble else { return }

                MiloMumbleEngine.shared.speak(line)
            }
        }
    }

    private func scheduleBubbleHide() {
        hideBubbleTask?.cancel()

        hideBubbleTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.bubbleVisibleNanoseconds ?? 3_000_000_000)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.soundTask?.cancel()
                self?.soundTask = nil
                guard !(self?.miloStateStore?.isContextMenuOpen ?? false) else { return }
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
        soundTask?.cancel()
    }
}
