//
//  MiloBubbleWindowController.swift
//  Milo
//

import AppKit
import Combine
import SwiftUI

private final class MiloBubbleState: ObservableObject {
    @Published var text: String = ""

    func configure(text: String) {
        self.text = text
    }
}

private struct MiloBubbleWrapperView: View {
    @ObservedObject var state: MiloBubbleState

    var body: some View {
        MiloReactionBubbleView(text: state.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

@MainActor
final class MiloBubbleWindowController {
    private var bubbleSize: NSSize {
        MiloOverlayDynamicTypeSizing.preferredBubbleSize()
    }
    private let bubbleState = MiloBubbleState()
    private var latestCharacterFrame: NSRect = .zero
    private var dynamicTypeObservers: [NSObjectProtocol] = []

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 360, height: 120),
        ignoresMouseEventsWhenVisible: true
    )

    func configure() {
        overlay.configure(
            rootView: AnyView(MiloBubbleWrapperView(state: bubbleState))
        )
        observeDynamicTypeChanges()
    }

    func show(text: String, relativeTo characterFrame: NSRect) {
        latestCharacterFrame = characterFrame
        bubbleState.configure(text: text)
        overlay.show(
            at: origin(relativeTo: characterFrame),
            size: bubbleSize,
            duration: nil
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
