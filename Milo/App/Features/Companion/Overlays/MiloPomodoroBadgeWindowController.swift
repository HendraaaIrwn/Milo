//
//  MiloPomodoroBadgeWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class MiloPomodoroBadgeWindowController {
    private let badgeSize = NSSize(width: 124, height: 124)

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 124, height: 124),
        ignoresMouseEventsWhenVisible: true
    )

    private let pomodoroService: PomodoroService

    init(pomodoroService: PomodoroService) {
        self.pomodoroService = pomodoroService
    }

    func configure() {
        overlay.configure(
            rootView: AnyView(
                MiloPomodoroTimerBadgeView(pomodoroService: pomodoroService)
                    .frame(width: badgeSize.width, height: badgeSize.height)
            )
        )
    }

    func show(relativeTo characterFrame: NSRect) {
        overlay.show(
            at: origin(relativeTo: characterFrame),
            size: badgeSize,
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
            x: characterFrame.midX - badgeSize.width / 2,
            y: characterFrame.minY - badgeSize.height - 62
        )
    }
}
