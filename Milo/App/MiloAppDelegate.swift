//
//  MiloAppDelegate.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import SwiftUI

@MainActor
final class MiloAppDelegate: NSObject, NSApplicationDelegate {
    private let petState = MiloFloatingPetState()
    private var petPanel: FloatingPetPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        showMilo()
    }

    func showMilo() {
        if let petPanel {
            petPanel.orderFrontRegardless()
            return
        }

        let size = NSSize(width: MiloRootView.windowWidth, height: MiloRootView.windowHeight)
        let origin = initialOrigin(for: size)
        let panel = FloatingPetPanel(
            contentRect: NSRect(origin: origin, size: size),
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
            rootView: MiloRootView(state: petState)
                .frame(width: size.width, height: size.height)
        )

        petPanel = panel
        panel.orderFrontRegardless()
    }

    func hideMilo() {
        petPanel?.orderOut(nil)
    }

    func startPomodoro() {
        petState.mood = .focus
        showMilo()
    }

    func addReminder() {
        petState.mood = .reminder
        showMilo()
    }

    func quit() {
        NSApp.terminate(nil)
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
