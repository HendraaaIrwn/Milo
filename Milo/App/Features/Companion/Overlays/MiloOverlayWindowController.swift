//
//  MiloOverlayWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class MiloOverlayWindowController<Content: View> {
    private var window: NSWindow?
    private var hostingController: NSHostingController<AnyView>?
    private weak var passThroughView: MiloOverlayPassThroughView?
    private var hideTask: Task<Void, Never>?
    private var mouseMoveMonitors: [Any] = []

    private let defaultSize: NSSize
    private let windowLevel: NSWindow.Level
    private let ignoresMouseEventsWhenVisible: Bool

    init(
        defaultSize: NSSize,
        windowLevel: NSWindow.Level = .floating,
        ignoresMouseEventsWhenVisible: Bool = true
    ) {
        self.defaultSize = defaultSize
        self.windowLevel = windowLevel
        self.ignoresMouseEventsWhenVisible = ignoresMouseEventsWhenVisible
    }

    func configure(rootView: Content, initialOrigin: NSPoint = .zero) {
        let wrappedRoot = AnyView(
            MiloHostingRoot.wrap {
                rootView
            }
            .coordinateSpace(name: "MiloOverlayWindow")
        )

        if let hostingController {
            hostingController.rootView = wrappedRoot
            return
        }

        let hosting = NSHostingController(rootView: wrappedRoot)
        let containerView = MiloOverlayPassThroughView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor
        hosting.view.frame = containerView.bounds
        hosting.view.autoresizingMask = [.width, .height]
        containerView.addSubview(hosting.view)

        let newWindow = NSWindow(
            contentRect: NSRect(origin: initialOrigin, size: defaultSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        newWindow.contentView = containerView
        newWindow.isOpaque = false
        newWindow.backgroundColor = .clear
        newWindow.hasShadow = false
        newWindow.level = windowLevel
        newWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        newWindow.isReleasedWhenClosed = false
        newWindow.ignoresMouseEvents = true
        newWindow.orderOut(nil)

        self.hostingController = hosting
        self.passThroughView = containerView
        self.window = newWindow
        installMouseMoveMonitorsIfNeeded()
    }

    func show(
        at origin: NSPoint,
        size: NSSize? = nil,
        duration: TimeInterval? = nil
    ) {
        guard let window else { return }

        hideTask?.cancel()
        hideTask = nil

        var frame = window.frame
        frame.origin = origin
        if let size { frame.size = size }

        window.setFrame(frame, display: true, animate: false)
        if passThroughView?.usesHitTestRegion == true {
            updateMousePassThrough()
        } else {
            window.ignoresMouseEvents = ignoresMouseEventsWhenVisible
        }
        window.orderFrontRegardless()

        if let duration {
            hideTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                await MainActor.run { self?.hide() }
            }
        }
    }

    func hide() {
        hideTask?.cancel()
        hideTask = nil
        window?.ignoresMouseEvents = true
        window?.orderOut(nil)
    }

    func updatePosition(_ origin: NSPoint) {
        guard let window, window.isVisible else { return }
        window.setFrameOrigin(origin)
    }

    func updateHitTestRegion(_ region: NSRect?) {
        passThroughView?.usesHitTestRegion = true

        guard let region else {
            passThroughView?.hitTestRegion = nil
            updateMousePassThrough()
            return
        }

        let windowHeight = frame.height
        passThroughView?.hitTestRegion = NSRect(
            x: region.minX,
            y: windowHeight - region.maxY,
            width: region.width,
            height: region.height
        )
        updateMousePassThrough()
    }

    func destroy() {
        hideTask?.cancel()
        hideTask = nil
        window?.orderOut(nil)
        window?.close()
        removeMouseMoveMonitors()
        window = nil
        hostingController = nil
        passThroughView = nil
    }

    var isVisible: Bool {
        window?.isVisible == true
    }

    var frame: NSRect {
        window?.frame ?? .zero
    }

    private func installMouseMoveMonitorsIfNeeded() {
        guard mouseMoveMonitors.isEmpty else { return }

        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            Task { @MainActor [weak self] in self?.updateMousePassThrough() }
        }
        if let globalMonitor {
            mouseMoveMonitors.append(globalMonitor)
        }

        if let localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved], handler: { [weak self] event in
            Task { @MainActor [weak self] in self?.updateMousePassThrough() }
            return event
        }) {
            mouseMoveMonitors.append(localMonitor)
        }
    }

    private func removeMouseMoveMonitors() {
        for monitor in mouseMoveMonitors {
            NSEvent.removeMonitor(monitor)
        }
        mouseMoveMonitors.removeAll()
    }

    private func updateMousePassThrough() {
        guard let window, window.isVisible, let passThroughView, passThroughView.usesHitTestRegion else { return }
        guard let hitTestRegion = passThroughView.hitTestRegion, !hitTestRegion.isEmpty else {
            window.ignoresMouseEvents = true
            return
        }

        let windowFrame = window.frame
        let mouseLocation = NSEvent.mouseLocation
        let pointInWindow = NSPoint(
            x: mouseLocation.x - windowFrame.minX,
            y: mouseLocation.y - windowFrame.minY
        )
        window.ignoresMouseEvents = !hitTestRegion.contains(pointInWindow)
    }
}

private final class MiloOverlayPassThroughView: NSView {
    var usesHitTestRegion = false
    var hitTestRegion: NSRect?

    override func hitTest(_ point: NSPoint) -> NSView? {
        if usesHitTestRegion {
            guard let hitTestRegion, !hitTestRegion.isEmpty, hitTestRegion.contains(point) else {
                return nil
            }
        }
        return super.hitTest(point)
    }
}
