//
//  MiloRightClickHitView.swift
//  Milo
//

import AppKit

extension Notification.Name {
    static let miloCharacterWindowDidMove = Notification.Name("miloCharacterWindowDidMove")
}

final class MiloRightClickHitView: NSView {
    var contextMenuController: MiloContextMenuController?
    var onLeftClick: (() -> Void)?

    private var didDrag = false
    private var mouseDownPoint: NSPoint?
    private var initialWindowOrigin: NSPoint?
    private var initialMouseScreenPoint: NSPoint?
    private var activeMenu: NSMenu?
    private let dragThreshold: CGFloat = 3

    override var acceptsFirstResponder: Bool { false }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func rightMouseDown(with event: NSEvent) {
        showContextMenu(event: event)
    }

    override func mouseDown(with event: NSEvent) {
        if isControlClick(event) {
            showContextMenu(event: event)
            return
        }

        didDrag = false
        mouseDownPoint = event.locationInWindow
        initialWindowOrigin = window?.frame.origin
        initialMouseScreenPoint = NSEvent.mouseLocation
    }

    override func mouseDragged(with event: NSEvent) {
        guard !isControlClick(event) else { return }
        guard shouldStartDrag(with: event) else { return }

        didDrag = true
        dragWindow()
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            didDrag = false
            mouseDownPoint = nil
            initialWindowOrigin = nil
            initialMouseScreenPoint = nil
        }

        guard !isControlClick(event) else { return }
        guard !didDrag else { return }

        onLeftClick?()
    }

    private func dragWindow() {
        guard let window,
              let initialWindowOrigin,
              let initialMouseScreenPoint
        else { return }

        let currentMouseScreen = NSEvent.mouseLocation
        let deltaX = currentMouseScreen.x - initialMouseScreenPoint.x
        let deltaY = currentMouseScreen.y - initialMouseScreenPoint.y

        var newOrigin = initialWindowOrigin
        newOrigin.x += deltaX
        newOrigin.y += deltaY

        window.setFrameOrigin(newOrigin)

        NotificationCenter.default.post(
            name: .miloCharacterWindowDidMove,
            object: window,
            userInfo: ["frame": NSValue(rect: window.frame)]
        )
    }

    private func showContextMenu(event: NSEvent) {
        guard let contextMenuController else {
            assertionFailure("MiloContextMenuController is nil. Make sure it is strongly retained.")
            return
        }

        let menu = contextMenuController.makeMenu()
        activeMenu = menu
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    private func shouldStartDrag(with event: NSEvent) -> Bool {
        guard let mouseDownPoint else { return true }
        let deltaX = abs(event.locationInWindow.x - mouseDownPoint.x)
        let deltaY = abs(event.locationInWindow.y - mouseDownPoint.y)
        return deltaX >= dragThreshold || deltaY >= dragThreshold
    }

    private func isControlClick(_ event: NSEvent) -> Bool {
        event.modifierFlags.contains(.control)
    }
}
