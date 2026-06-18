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
    private let bubbleSize = NSSize(width: 360, height: 120)
    private let bubbleState = MiloBubbleState()

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 360, height: 120),
        ignoresMouseEventsWhenVisible: true
    )

    func configure() {
        overlay.configure(
            rootView: AnyView(MiloBubbleWrapperView(state: bubbleState))
        )
    }

    func show(text: String, relativeTo characterFrame: NSRect) {
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
        overlay.updatePosition(origin(relativeTo: characterFrame))
    }

    func destroy() {
        overlay.destroy()
    }

    var isVisible: Bool { overlay.isVisible }

    private func origin(relativeTo characterFrame: NSRect) -> NSPoint {
        NSPoint(
            x: characterFrame.midX - bubbleSize.width / 2,
            y: characterFrame.maxY + 8
        )
    }
}
