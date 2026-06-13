//
//  MiloWindowController.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class MiloWindowController {
    private let petState = MiloFloatingPetState()
    private let stateStore: MiloStateStore
    private let reminderService: ReminderService
    private var petPanel: FloatingPetPanel?
    private var stateCancellable: AnyCancellable?

    init(stateStore: MiloStateStore, reminderService: ReminderService) {
        self.stateStore = stateStore
        self.reminderService = reminderService
        observeStateStore(stateStore)
    }

    func showMilo() {
        if let petPanel {
            petPanel.orderFrontRegardless()
            return
        }

        let size = NSSize(width: MiloRootView.windowWidth, height: MiloRootView.windowHeight)
        let panel = FloatingPetPanel(
            contentRect: NSRect(origin: initialOrigin(for: size), size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.acceptsMouseMovedEvents = true
        panel.minSize = size
        panel.maxSize = size
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .ignoresCycle,
            .stationary
        ]

        panel.contentView = DraggableHostingView(
            rootView: MiloRootView(
                state: petState,
                stateStore: stateStore,
                onAddReminder: { [weak self] in
                    self?.openReminderEntry(source: .rightClick)
                },
                onHideMilo: { [weak self] in
                    self?.hideMilo()
                }
            )
                .frame(width: size.width, height: size.height)
        )

        petPanel = panel
        panel.orderFrontRegardless()
    }

    func hideMilo() {
        petPanel?.orderOut(nil)
    }

    func setMood(_ mood: MiloMood) {
        petState.mood = mood
    }

    func showBubble(_ text: String, mood: MiloMood? = nil) {
        if let mood {
            petState.mood = mood
        }

        showMilo()
        petState.showBubble(text)
    }

    func openReminderEntry(source: ReminderSource) {
        reminderService.openReminderEntryWindow(source: source) { [weak self] reminder in
            ReminderNotificationService.shared.scheduleNotification(for: reminder)
            self?.showBubble("Reminder saved.", mood: .reminder)
        }
    }

    func close() {
        stateCancellable?.cancel()
        stateCancellable = nil
        petState.clearBubble()
        petPanel?.close()
        petPanel = nil
    }

    private func observeStateStore(_ stateStore: MiloStateStore) {
        stateCancellable = stateStore.$animationState
            .sink { [weak self] animationState in
                Task { @MainActor [weak self] in
                    self?.petState.mood = animationState.miloMood
                }
            }
    }

    private func initialOrigin(for size: NSSize) -> NSPoint {
        guard let visibleFrame = NSScreen.main?.visibleFrame else { return .zero }

        return NSPoint(
            x: visibleFrame.midX - size.width * 0.5,
            y: visibleFrame.midY - size.height * 0.5
        )
    }
}

final class FloatingPetPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

final class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { true }
}
