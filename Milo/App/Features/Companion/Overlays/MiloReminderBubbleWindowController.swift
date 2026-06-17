//
//  MiloReminderBubbleWindowController.swift
//  Milo
//

import AppKit
import Combine
import SwiftUI

private final class MiloReminderBubbleState: ObservableObject {
    @Published var reminder: MiloReminder?
    @Published var onDone: (() -> Void)?
    @Published var onSnooze5: (() -> Void)?
    @Published var onSnooze15: (() -> Void)?
    @Published var onReschedule: (() -> Void)?

    func configure(
        reminder: MiloReminder,
        onDone: @escaping () -> Void,
        onSnooze5: @escaping () -> Void,
        onSnooze15: @escaping () -> Void,
        onReschedule: @escaping () -> Void
    ) {
        self.reminder = reminder
        self.onDone = onDone
        self.onSnooze5 = onSnooze5
        self.onSnooze15 = onSnooze15
        self.onReschedule = onReschedule
    }
}

private struct MiloReminderBubbleWrapperView: View {
    @ObservedObject var state: MiloReminderBubbleState

    var body: some View {
        if let reminder = state.reminder,
           let onDone = state.onDone,
           let onSnooze5 = state.onSnooze5,
           let onSnooze15 = state.onSnooze15,
           let onReschedule = state.onReschedule
        {
            MiloReminderBubbleView(
                reminder: reminder,
                onDone: onDone,
                onSnooze5: onSnooze5,
                onSnooze15: onSnooze15,
                onReschedule: onReschedule
            )
            .environment(\.controlActiveState, .active)
            .frame(width: 320, height: 130)
        } else {
            Color.clear.frame(width: 320, height: 130)
        }
    }
}

@MainActor
final class MiloReminderBubbleWindowController {
    private let bubbleSize = NSSize(width: 320, height: 130)
    private let bubbleState = MiloReminderBubbleState()

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 320, height: 130),
        ignoresMouseEventsWhenVisible: false
    )

    func configure() {
        overlay.configure(
            rootView: AnyView(
                MiloReminderBubbleWrapperView(state: bubbleState)
            )
        )
    }

    func show(
        reminder: MiloReminder,
        relativeTo characterFrame: NSRect,
        duration: TimeInterval? = nil,
        onDone: @escaping () -> Void,
        onSnooze5: @escaping () -> Void,
        onSnooze15: @escaping () -> Void,
        onReschedule: @escaping () -> Void
    ) {
        bubbleState.configure(
            reminder: reminder,
            onDone: onDone,
            onSnooze5: onSnooze5,
            onSnooze15: onSnooze15,
            onReschedule: onReschedule
        )
        overlay.show(
            at: origin(relativeTo: characterFrame),
            size: bubbleSize,
            duration: duration
        )
    }

    func hide() {
        overlay.hide()
    }

    func updatePosition(relativeTo characterFrame: NSRect) {
        overlay.updatePosition(origin(relativeTo: characterFrame))
    }

    func destroy() {
        overlay.destroy()
    }

    var isVisible: Bool { overlay.isVisible }

    private func origin(relativeTo characterFrame: NSRect) -> NSPoint {
        NSPoint(
            x: characterFrame.midX - bubbleSize.width / 2,
            y: characterFrame.maxY - 4
        )
    }
}
