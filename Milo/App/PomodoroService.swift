//
//  PomodoroService.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import Combine
import Foundation

@MainActor
final class PomodoroService: ObservableObject {
    static let focusSeconds = 25 * 60
    static let breakSeconds = 5 * 60

    @Published private(set) var isRunning = false
    @Published private(set) var isPaused = false
    @Published private(set) var remainingSeconds = PomodoroService.focusSeconds

    private var timer: Timer?

    func startDefaultPomodoro() {
        guard !isRunning else { return }

        isRunning = true
        isPaused = false
        remainingSeconds = Self.focusSeconds
        startTimer()
        print("Pomodoro started")
    }

    func pause() {
        guard isRunning, !isPaused else { return }

        isPaused = true
        timer?.invalidate()
        timer = nil
        print("Pomodoro paused")
    }

    func resume() {
        guard isRunning, isPaused else { return }

        isPaused = false
        startTimer()
        print("Pomodoro resumed")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        remainingSeconds = Self.focusSeconds
    }

    private func startTimer() {
        timer?.invalidate()

        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func tick() {
        guard isRunning, !isPaused else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            stop()
            print("Pomodoro finished. Break preset is \(Self.breakSeconds / 60) minutes")
        }
    }
}
