//
//  CodingMetricsBadgeWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class CodingMetricsBadgeWindowController {
    private let badgeSize = NSSize(width: 150, height: 48)

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 150, height: 48),
        ignoresMouseEventsWhenVisible: true
    )

    private let service: CodingMetricsService

    init(service: CodingMetricsService) {
        self.service = service
    }

    func configure() {
        overlay.configure(
            rootView: AnyView(
                CodingMetricsBadgeView(service: service)
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
            y: characterFrame.minY - badgeSize.height - 6
        )
    }
}
