//
//  FileWatcherSettingsWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class FileWatcherSettingsWindowController {
    private var window: NSWindow?
    private var windowDelegate: Delegate?
    private let sizing = MiloPanelSizing.fileWatcherSettings

    private let fileWatcherService: ProjectFileWatcherService

    init(fileWatcherService: ProjectFileWatcherService) {
        self.fileWatcherService = fileWatcherService
    }

    func show() {
        if let window {
            centerOnCurrentScreen(window)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let host = NSHostingController(
            rootView: MiloDynamicTypeDebugWrapper {
                FileWatcherSettingsView(fileWatcherService: fileWatcherService)
            }
        )

        let win = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: sizing.defaultSize.width,
                height: sizing.defaultSize.height
            ),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        win.title = "File Watcher Settings"
        win.contentViewController = host
        win.minSize = sizing.minSize
        win.isReleasedWhenClosed = false
        centerOnCurrentScreen(win)

        let delegate = Delegate { [weak self] in
            self?.window = nil
            self?.windowDelegate = nil
        }
        win.delegate = delegate
        self.windowDelegate = delegate
        self.window = win

        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func centerOnCurrentScreen(_ window: NSWindow) {
        let screenFrame = (NSScreen.main ?? window.screen)?.visibleFrame ?? .zero
        guard screenFrame != .zero else {
            window.center()
            return
        }

        var frame = window.frame
        frame.origin = NSPoint(
            x: screenFrame.midX - frame.width / 2,
            y: screenFrame.midY - frame.height / 2
        )
        window.setFrame(frame, display: true)
    }
}

private final class Delegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
