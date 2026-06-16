//
//  MiloRightClickHitView.swift
//  Milo
//

import AppKit

final class MiloRightClickHitView: NSView {
    var contextMenuController: MiloContextMenuController?
    var onLeftClick: (() -> Void)?

    private var didDrag = false
    private var mouseDownPoint: NSPoint?
    private var activeMenu: NSMenu?
    private let dragThreshold: CGFloat = 3

    override var acceptsFirstResponder: Bool { false }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func rightMouseDown(with event: NSEvent) {
        print("MILO rightMouseDown")
        showContextMenu(event: event)
    }

    override func mouseDown(with event: NSEvent) {
        print("MILO mouseDown")

        if isControlClick(event) {
            showContextMenu(event: event)
            return
        }

        didDrag = false
        mouseDownPoint = event.locationInWindow
    }

    override func mouseDragged(with event: NSEvent) {
        print("MILO mouseDragged")

        guard !isControlClick(event) else { return }
        guard shouldStartDrag(with: event) else { return }

        didDrag = true
        window?.performDrag(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        print("MILO mouseUp")

        defer {
            didDrag = false
            mouseDownPoint = nil
        }

        guard !isControlClick(event) else { return }
        guard !didDrag else { return }

        onLeftClick?()
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
