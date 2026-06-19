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
    let onVisualFrameChange: (CGRect) -> Void

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
                onReschedule: onReschedule,
                onVisualFrameChange: onVisualFrameChange
            )
            .environment(\.controlActiveState, .active)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        } else {
            Color.clear.frame(width: 660, height: 200)
        }
    }
}

@MainActor
final class MiloReminderBubbleWindowController {
    private var bubbleSize: NSSize {
        MiloMacDynamicTypeObserver.currentDynamicTypeSize().isAccessibilitySize
            ? NSSize(width: 800, height: 280)
            : NSSize(width: 660, height: 210)
    }
    private let bubbleState = MiloReminderBubbleState()
    private var latestCharacterFrame: NSRect = .zero
    private var dynamicTypeObservers: [NSObjectProtocol] = []

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 660, height: 210),
        ignoresMouseEventsWhenVisible: false
    )

    func configure() {
        overlay.configure(
            rootView: AnyView(
                MiloReminderBubbleWrapperView(
                    state: bubbleState,
                    onVisualFrameChange: { [weak self] rect in
                        self?.overlay.updateHitTestRegion(
                            NSRect(
                                x: rect.origin.x,
                                y: rect.origin.y,
                                width: rect.width,
                                height: rect.height
                            )
                        )
                    }
                )
            )
        )
        overlay.updateHitTestRegion(.zero)
        observeDynamicTypeChanges()
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
        latestCharacterFrame = characterFrame
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
        latestCharacterFrame = characterFrame
        overlay.updatePosition(origin(relativeTo: characterFrame))
    }

    func destroy() {
        for observer in dynamicTypeObservers {
            NotificationCenter.default.removeObserver(observer)
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        dynamicTypeObservers.removeAll()
        overlay.destroy()
    }

    var isVisible: Bool { overlay.isVisible }

    private func origin(relativeTo characterFrame: NSRect) -> NSPoint {
        NSPoint(
            x: characterFrame.midX - bubbleSize.width / 2,
            y: characterFrame.maxY + 8 
        )
    }

    private func observeDynamicTypeChanges() {
        guard dynamicTypeObservers.isEmpty else { return }

        dynamicTypeObservers.append(
            NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshDynamicTypeSize() }
            }
        )
        dynamicTypeObservers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshDynamicTypeSize() }
            }
        )
    }

    private func refreshDynamicTypeSize() {
        guard isVisible else { return }
        overlay.show(
            at: origin(relativeTo: latestCharacterFrame),
            size: bubbleSize,
            duration: nil
        )
    }
}
