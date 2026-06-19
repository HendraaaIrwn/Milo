//
//  CodingMetricsBadgeWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class CodingMetricsBadgeWindowController {
    private var badgeSize: NSSize {
        MiloOverlayDynamicTypeSizing.preferredBadgeSize()
    }
    private var latestCharacterFrame: NSRect = .zero
    private var dynamicTypeObservers: [NSObjectProtocol] = []

    private let overlay = MiloOverlayWindowController<AnyView>(
        defaultSize: NSSize(width: 220, height: 48),
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        )
        observeDynamicTypeChanges()
    }

    func show(relativeTo characterFrame: NSRect) {
        latestCharacterFrame = characterFrame
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
            x: characterFrame.midX - badgeSize.width / 2,
            y: characterFrame.minY - badgeSize.height - 6
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
            size: badgeSize,
            duration: nil
        )
    }
}
