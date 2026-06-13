//
//  MiloBlinkEngine.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import Foundation
import Observation

enum BlinkPhase: Equatable {
    case open
    case threeQuarter
    case halfClosed
    case mostlyClosed
    case closed
}

@MainActor
@Observable
final class MiloBlinkEngine {
    var isBlinking: Bool = false

    var phase: BlinkPhase = .open

    var frequencyPerSecond: Double = 0.25

    private var task: Task<Void, Never>?

    func start() {
        guard task == nil else { return }
        task = Task { [weak self] in
            await self?.runLoop()
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        isBlinking = false
        phase = .open
    }

    private func runLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }

            let roll = Double.random(in: 0..<1)
            guard roll < frequencyPerSecond else { continue }

            await performBlink()
        }
    }

    private func performBlink() async {
        isBlinking = true

        phase = .threeQuarter
        try? await Task.sleep(for: .milliseconds(32))

        phase = .halfClosed
        try? await Task.sleep(for: .milliseconds(34))

        phase = .mostlyClosed
        try? await Task.sleep(for: .milliseconds(36))

        phase = .closed
        try? await Task.sleep(for: .milliseconds(40))

        phase = .mostlyClosed
        try? await Task.sleep(for: .milliseconds(36))

        phase = .halfClosed
        try? await Task.sleep(for: .milliseconds(34))

        phase = .threeQuarter
        try? await Task.sleep(for: .milliseconds(32))

        phase = .open
        isBlinking = false
    }
}
