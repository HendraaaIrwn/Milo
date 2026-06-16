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

    private let fileWatcherService: ProjectFileWatcherService

    init(fileWatcherService: ProjectFileWatcherService) {
        self.fileWatcherService = fileWatcherService
    }

    func show() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let host = NSHostingController(
            rootView: FileWatcherSettingsView(fileWatcherService: fileWatcherService)
        )

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        win.title = "File Watcher Settings"
        win.contentViewController = host
        win.minSize = NSSize(width: 560, height: 500)
        win.isReleasedWhenClosed = false
        win.center()

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
