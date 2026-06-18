//
//  MiloAgentStatusBadgeWindowController.swift
//  Milo
//
//  PRIVACY: Displays agent status as a small badge below MILO.
//  Ignores mouse events — non-interactive overlay.
//  Reuses window — never recreates on every poll.
//

import AppKit
import SwiftUI

private struct AgentBadgeSnapshot: Equatable {
    let agentType: MiloAgentType
    let state: MiloAgentState
    let title: String
    init(_ event: MiloAgentEvent) {
        self.agentType = event.agentType
        self.state = event.state
        self.title = event.title
    }
}

@MainActor
final class MiloAgentStatusBadgeWindowController {
    private let badgeSize = NSSize(width: 180, height: 34)
    private var window: NSWindow?
    private var hostingController: NSHostingController<MiloAgentStatusBadgeView>?
    private var lastSnapshot: AgentBadgeSnapshot?

    func configure() {}

    var isVisible: Bool { window?.isVisible == true }

    func show(event: MiloAgentEvent, relativeTo characterFrame: NSRect) {
        let snapshot = AgentBadgeSnapshot(event)

        if window == nil {
            let newWindow = NSWindow(
                contentRect: NSRect(origin: .zero, size: badgeSize),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            newWindow.isOpaque = false
            newWindow.backgroundColor = .clear
            newWindow.hasShadow = false
            newWindow.level = .floating
            newWindow.ignoresMouseEvents = true
            newWindow.isReleasedWhenClosed = false
            newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

            let placeholder = MiloAgentStatusBadgeView(event: MiloAgentEvent(agentType: .unknown, state: .idle, title: "", detail: nil))
            let hosting = NSHostingController(rootView: placeholder)
            newWindow.contentViewController = hosting

            window = newWindow
            hostingController = hosting
        }

        if lastSnapshot != snapshot {
            hostingController?.rootView = MiloAgentStatusBadgeView(event: event)
            lastSnapshot = snapshot
        }

        let origin = NSPoint(
            x: characterFrame.midX - badgeSize.width / 2,
            y: characterFrame.minY - badgeSize.height - 48
        )
        window?.setFrame(NSRect(origin: origin, size: badgeSize), display: true, animate: false)
        window?.orderFrontRegardless()
    }

    func hide() { window?.orderOut(nil) }

    func updatePosition(relativeTo characterFrame: NSRect) {
        guard let window else { return }
        let origin = NSPoint(
            x: characterFrame.midX - badgeSize.width / 2,
            y: characterFrame.minY - badgeSize.height - 48
        )
        window.setFrameOrigin(origin)
    }

    func destroy() {
        window?.orderOut(nil)
        window?.close()
        window = nil
        hostingController = nil
        lastSnapshot = nil
    }
}
