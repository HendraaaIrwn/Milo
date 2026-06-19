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
    private var hideTask: Task<Void, Never>?

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
        )

        if let hostingController {
            hostingController.rootView = wrappedRoot
            return
        }

        let hosting = NSHostingController(rootView: wrappedRoot)

        let newWindow = NSWindow(
            contentRect: NSRect(origin: initialOrigin, size: defaultSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        newWindow.contentViewController = hosting
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
        self.window = newWindow
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
        window.ignoresMouseEvents = ignoresMouseEventsWhenVisible
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

    func destroy() {
        hideTask?.cancel()
        hideTask = nil
        window?.orderOut(nil)
        window?.close()
        window = nil
        hostingController = nil
    }

    var isVisible: Bool {
        window?.isVisible == true
    }

    var frame: NSRect {
        window?.frame ?? .zero
    }
}
