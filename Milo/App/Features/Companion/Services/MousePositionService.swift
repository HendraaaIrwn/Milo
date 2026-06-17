//
//  MousePositionService.swift
//  Milo
//

import AppKit
import Combine
import Foundation

@MainActor
final class MousePositionService: ObservableObject {
    @Published private(set) var mouseLocation: NSPoint = NSEvent.mouseLocation

    private var timer: Timer?

    func start() {
        stop()

        let timer = Timer(
            timeInterval: 1.0 / 30.0,
            repeats: true
        ) { [weak self] _ in
            let location = NSEvent.mouseLocation
            Task { @MainActor [weak self] in
                self?.mouseLocation = location
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
