//
//  TrackingMouseView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI
#if os(macOS)
import AppKit

struct TrackingMouseView: NSViewRepresentable {
    var onMove: (_ point: CGPoint) -> Void
    var onExit: () -> Void = {}

    func makeNSView(context: Context) -> TrackingNSView {
        let view = TrackingNSView()
        view.onMove = onMove
        view.onExit = onExit
        return view
    }

    func updateNSView(_ nsView: TrackingNSView, context: Context) {
        nsView.onMove = onMove
        nsView.onExit = onExit
    }

    final class TrackingNSView: NSView {
        var onMove: ((CGPoint) -> Void)?
        var onExit: (() -> Void)?

        private var trackingArea: NSTrackingArea?
        private var timer: Timer?
        private var lastPoint: CGPoint?

        override var isFlipped: Bool { true }

        override func hitTest(_ point: NSPoint) -> NSView? {
            nil
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            window?.acceptsMouseMovedEvents = true

            if window == nil {
                stopTrackingMouseGlobally()
            } else {
                startTrackingMouseGlobally()
            }
        }

        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            needsDisplay = true
        }

        deinit {
            stopTrackingMouseGlobally()
        }

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if let trackingArea { removeTrackingArea(trackingArea) }

            let options: NSTrackingArea.Options = [
                .mouseMoved,
                .mouseEnteredAndExited,
                .activeAlways,
                .inVisibleRect,
                .enabledDuringMouseDrag
            ]
            let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
            addTrackingArea(area)
            trackingArea = area
        }

        override func mouseMoved(with event: NSEvent) {
            report(event.locationInWindow)
        }

        override func mouseEntered(with event: NSEvent) {
            report(event.locationInWindow)
        }

        override func mouseDragged(with event: NSEvent) {
            report(event.locationInWindow)
        }

        override func mouseExited(with event: NSEvent) {
            reportCurrentMouseLocation()
        }

        private func startTrackingMouseGlobally() {
            guard timer == nil else { return }

            let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
                self?.reportCurrentMouseLocation()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
            reportCurrentMouseLocation()
        }

        private func stopTrackingMouseGlobally() {
            timer?.invalidate()
            timer = nil
            lastPoint = nil
            onExit?()
        }

        private func reportCurrentMouseLocation() {
            guard let window else { return }
            report(window.convertPoint(fromScreen: NSEvent.mouseLocation))
        }

        private func report(_ windowPoint: CGPoint) {
            let point = convert(windowPoint, from: nil)
            guard lastPoint != point else { return }
            lastPoint = point
            onMove?(point)
        }
    }
}
#endif
