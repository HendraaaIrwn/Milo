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
        if nsView.window != nil, nsView.timer == nil {
            nsView.startTrackingMouseGlobally()
        }
    }

    final class TrackingNSView: NSView {
        var onMove: ((CGPoint) -> Void)?
        var onExit: (() -> Void)?

        private(set) var trackingArea: NSTrackingArea?
        private(set) var timer: Timer?
        private var localMonitor: Any?
        private var globalMonitor: Any?
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
            #if DEBUG
            print("[TrackingNSView] viewDidMoveToWindow – window=\(window != nil), bounds=\(bounds), timer=\(timer != nil)")
            #endif
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

        func startTrackingMouseGlobally() {
            guard timer == nil else { return }
            #if DEBUG
            print("[TrackingNSView] startTrackingMouseGlobally – bounds=\(bounds)")
            #endif

            localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]) { [weak self] event in
                self?.reportCurrentMouseLocation()
                return event
            }

            globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]) { [weak self] _ in
                self?.reportCurrentMouseLocation()
            }

            let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
                self?.reportCurrentMouseLocation()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
            reportCurrentMouseLocation()
        }

        private func stopTrackingMouseGlobally() {
            if let localMonitor {
                NSEvent.removeMonitor(localMonitor)
                self.localMonitor = nil
            }

            if let globalMonitor {
                NSEvent.removeMonitor(globalMonitor)
                self.globalMonitor = nil
            }

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
            #if DEBUG
            if lastPoint == nil || abs(point.x - (lastPoint?.x ?? 0)) > 50 || abs(point.y - (lastPoint?.y ?? 0)) > 50 {
                print("[TrackingNSView] report – windowPoint=\(windowPoint), viewPoint=\(point), bounds=\(bounds), frameInWindow=\(convert(bounds, to: nil))")
            }
            #endif
            guard lastPoint != point else { return }
            lastPoint = point
            onMove?(point)
        }
    }
}
#endif
