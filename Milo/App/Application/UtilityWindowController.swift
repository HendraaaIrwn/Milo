//
//  UtilityWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class UtilityWindowController {
    private var window: NSWindow?
    private var windowDelegate: NSObject?

    private let title: String
    private let sizing: MiloPanelSizing
    private let rootViewProvider: () -> AnyView

    var onClose: (() -> Void)?

    init<Content: View>(
        title: String,
        sizing: MiloPanelSizing,
        rootView: Content
    ) {
        self.title = title
        self.sizing = sizing
        self.rootViewProvider = {
            AnyView(
                rootView
                    .frame(
                        minWidth: sizing.minSize.width,
                        minHeight: sizing.minSize.height
                    )
            )
        }
    }

    func show() {
        if let window {
            ensureWindowSize(window)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let host = NSHostingController(rootView: rootViewProvider())

        let win = NSWindow(
            contentRect: NSRect(
                x: 0, y: 0,
                width: sizing.defaultSize.width,
                height: sizing.defaultSize.height
            ),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        win.title = title
        win.contentViewController = host
        win.minSize = sizing.minSize
        win.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        win.isReleasedWhenClosed = false
        win.center()

        let delegate = Delegate { [weak self] in
            self?.window = nil
            self?.windowDelegate = nil
            self?.onClose?()
        }
        win.delegate = delegate
        self.windowDelegate = delegate
        self.window = win

        ensureWindowSize(win)

        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
        window = nil
        windowDelegate = nil
    }

    func ensureMinimumSize(_ size: CGSize) {
        guard let window else { return }

        window.minSize = NSSize(width: size.width, height: size.height)

        let current = window.frame
        let newWidth = max(current.width, size.width)
        let newHeight = max(current.height, size.height)

        guard newWidth != current.width || newHeight != current.height else { return }

        window.setFrame(
            NSRect(
                x: current.origin.x,
                y: current.origin.y,
                width: newWidth,
                height: newHeight
            ),
            display: true,
            animate: false
        )
    }

    private func ensureWindowSize(_ win: NSWindow) {
        let current = win.frame
        let needWidth = current.width < sizing.minSize.width
            || current.width < sizing.defaultSize.width * 0.75
        let needHeight = current.height < sizing.minSize.height
            || current.height < sizing.defaultSize.height * 0.75

        guard needWidth || needHeight else { return }

        let targetWidth = max(current.width, sizing.defaultSize.width)
        let targetHeight = max(current.height, sizing.defaultSize.height)

        var newFrame = current
        newFrame.size = NSSize(width: targetWidth, height: targetHeight)

        win.setFrame(newFrame, display: true, animate: false)
        win.center()
    }
}

private final class Delegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void
    init(onClose: @escaping () -> Void) { self.onClose = onClose }
    func windowWillClose(_ notification: Notification) { onClose() }
}
