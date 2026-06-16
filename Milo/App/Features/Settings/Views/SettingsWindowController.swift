//
//  SettingsWindowController.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    private var window: NSWindow?
    private var windowDelegate: NSObject?

    private let dependencies: SettingsDependencies

    init(dependencies: SettingsDependencies) {
        self.dependencies = dependencies
    }

    func show(initialSection: SettingsSection = .general) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let host = NSHostingController(
            rootView: MiloSettingsView(
                dependencies: dependencies,
                initialSection: initialSection
            )
        )

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        win.title = "MILO Settings"
        win.contentViewController = host
        win.minSize = NSSize(width: 640, height: 520)
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
    init(onClose: @escaping () -> Void) { self.onClose = onClose }
    func windowWillClose(_ notification: Notification) { onClose() }
}
