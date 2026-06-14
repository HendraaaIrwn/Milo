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

    @Published private(set) var session: PomodoroSession
    @Published private(set) var stats: PomodoroStats

    private let storage: MiloLocalStorageService
    private var timerTask: Task<Void, Never>?

    var onFocusCompleted: (() -> Void)?
    var onBreakStarted: (() -> Void)?
    var onBreakCompleted: (() -> Void)?

    var isRunning: Bool {
        session.runState == .running || session.runState == .paused
    }

    var isPaused: Bool {
        session.runState == .paused
    }

    var remainingSeconds: Int {
        session.remainingSeconds
    }

    init(storage: MiloLocalStorageService = .shared) {
        self.storage = storage

        var loadedSession = storage.load(
            PomodoroSession.self,
            forKey: MiloStorageKeys.pomodoroSession,
            defaultValue: PomodoroSession()
        )

        if loadedSession.runState == .running {
            loadedSession.runState = .paused
            loadedSession.pausedAt = Date()
        }

        self.session = loadedSession

        let loadedStats = storage.load(
            PomodoroStats.self,
            forKey: MiloStorageKeys.pomodoroStats,
            defaultValue: PomodoroStats.empty()
        )

        if loadedStats.dateKey == PomodoroStats.makeDateKey(Date()) {
            self.stats = loadedStats
        } else {
            self.stats = PomodoroStats.empty()
            self.stats.streakDays = loadedStats.streakDays
            self.stats.lastCompletedFocusDate = loadedStats.lastCompletedFocusDate
        }

        save()
    }

    func startDefaultPomodoro() {
        start(preset: .short)
    }

    func start(preset: PomodoroPreset) {
        stopTimer()

        session = PomodoroSession(
            preset: preset,
            mode: .focus,
            runState: .running,
            startedAt: Date(),
            pausedAt: nil,
            remainingSeconds: preset.focusSeconds,
            totalFocusSeconds: preset.focusSeconds,
            totalBreakSeconds: preset.breakSeconds,
            completedFocus: false
        )

        UserDefaults.standard.set(preset.id, forKey: MiloStorageKeys.selectedPomodoroPreset)
        save()
        startTimer()
    }

    func pause() {
        guard session.runState == .running else { return }

        session.runState = .paused
        session.pausedAt = Date()

        stopTimer()
        save()
    }

    func resume() {
        guard session.runState == .paused else { return }

        session.runState = .running
        session.pausedAt = nil

        save()
        startTimer()
    }

    func reset() {
        stopTimer()

        session = PomodoroSession(
            preset: session.preset,
            remainingSeconds: session.preset.focusSeconds,
            totalFocusSeconds: session.preset.focusSeconds,
            totalBreakSeconds: session.preset.breakSeconds
        )

        save()
    }

    func stop() {
        reset()
    }

    func skipBreak() {
        guard session.mode == .breakTime else { return }

        stats.skippedBreaksToday += 1
        session.mode = .focus
        session.runState = .idle
        session.remainingSeconds = session.preset.focusSeconds
        session.completedFocus = false

        stopTimer()
        save()
    }

    func progress() -> Double {
        let total: Int

        switch session.mode {
        case .focus:
            total = session.totalFocusSeconds
        case .breakTime:
            total = session.totalBreakSeconds
        }

        guard total > 0 else { return 0 }
        return 1.0 - Double(session.remainingSeconds) / Double(total)
    }

    func formattedRemainingTime() -> String {
        let minutes = max(0, session.remainingSeconds) / 60
        let seconds = max(0, session.remainingSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func resetStatsToday() {
        let previousStreak = stats.streakDays
        let previousLastCompleted = stats.lastCompletedFocusDate
        stats = PomodoroStats.empty()
        stats.streakDays = previousStreak
        stats.lastCompletedFocusDate = previousLastCompleted
        save()
    }

    func save() {
        storage.save(session, forKey: MiloStorageKeys.pomodoroSession)
        storage.save(stats, forKey: MiloStorageKeys.pomodoroStats)
    }

    private func startTimer() {
        stopTimer()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                await MainActor.run {
                    self?.tick()
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func tick() {
        guard session.runState == .running else { return }

        if session.remainingSeconds > 0 {
            session.remainingSeconds -= 1
            save()
            return
        }

        completeCurrentMode()
    }

    private func completeCurrentMode() {
        switch session.mode {
        case .focus:
            completeFocus()
        case .breakTime:
            completeBreak()
        }
    }

    private func completeFocus() {
        let now = Date()

        updateDailyStatsIfNeeded(now: now)
        stats.pomodorosToday += 1
        stats.totalFocusSecondsToday += session.totalFocusSeconds
        updateStreak(completedAt: now)
        stats.lastCompletedFocusDate = now

        session.completedFocus = true
        session.mode = .breakTime
        session.runState = .running
        session.remainingSeconds = session.totalBreakSeconds

        save()

        onFocusCompleted?()
        onBreakStarted?()
    }

    private func completeBreak() {
        session.mode = .focus
        session.runState = .idle
        session.remainingSeconds = session.totalFocusSeconds
        session.completedFocus = false

        stopTimer()
        save()

        onBreakCompleted?()
    }

    private func updateDailyStatsIfNeeded(now: Date) {
        let todayKey = PomodoroStats.makeDateKey(now)
        guard stats.dateKey != todayKey else { return }

        let previousStreak = stats.streakDays
        let previousLastCompleted = stats.lastCompletedFocusDate
        stats = PomodoroStats.empty(for: now)
        stats.streakDays = previousStreak
        stats.lastCompletedFocusDate = previousLastCompleted
    }

    private func updateStreak(completedAt date: Date) {
        guard let lastCompletedFocusDate = stats.lastCompletedFocusDate else {
            stats.streakDays = max(1, stats.streakDays)
            return
        }

        let calendar = Calendar.current
        if calendar.isDate(lastCompletedFocusDate, inSameDayAs: date) {
            stats.streakDays = max(1, stats.streakDays)
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: date),
           calendar.isDate(lastCompletedFocusDate, inSameDayAs: yesterday) {
            stats.streakDays = max(1, stats.streakDays + 1)
        } else {
            stats.streakDays = 1
        }
    }

    deinit {
        timerTask?.cancel()
    }
}
