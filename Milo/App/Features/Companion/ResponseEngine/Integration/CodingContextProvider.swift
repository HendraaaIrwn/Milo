//
//  CodingContextProvider.swift
//  Milo
//
//  PRIVACY: Builds CodingContext from safe metadata summaries only.
//  Does not inspect typed text, source code, clipboard, or private content.
//

import Foundation

@MainActor
final class CodingContextProvider {
    private let codingMetricsService: CodingMetricsService
    private let stateStore: MiloStateStore
    private let pomodoroService: PomodoroService
    private let todoService: TodoService
    private let reminderService: ReminderService

    init(
        codingMetricsService: CodingMetricsService,
        stateStore: MiloStateStore,
        pomodoroService: PomodoroService,
        todoService: TodoService,
        reminderService: ReminderService
    ) {
        self.codingMetricsService = codingMetricsService
        self.stateStore = stateStore
        self.pomodoroService = pomodoroService
        self.todoService = todoService
        self.reminderService = reminderService
    }

    func makeContext() -> CodingContext {
        let now = Date()
        let snapshot = codingMetricsService.snapshot

        let idleSeconds: Int = {
            if let lastActivity = stateStore.lastKeyboardEventAt {
                return max(0, Int(now.timeIntervalSince(lastActivity)))
            }
            return 0
        }()

        let pomodoroState: MiloPomodoroState = {
            switch pomodoroService.session.runState {
            case .running: return .focusing
            case .paused:  return .paused
            case .completed, .idle:
                switch pomodoroService.session.mode {
                case .breakTime: return .breakTime
                case .focus:     return .idle
                }
            }
        }()

        return CodingContext(
            now: now,
            activeCodingMinutesToday: snapshot.codingSecondsToday / 60,
            currentFocusMinutes: snapshot.currentSessionSeconds / 60,
            idleMinutes: idleSeconds / 60,
            typingIntensity: stateStore.typingIntensity,
            activeProjectName: snapshot.topProject,
            activeLanguage: snapshot.topLanguage,
            activeEditorName: snapshot.topEditor,
            todoCount: todoService.activeTodoCount(),
            overdueTodoCount: todoService.overdueTodos().count,
            reminderDueCount: reminderService.dueReminders().count,
            pomodoroState: pomodoroState,
            completedPomodoroCountToday: pomodoroService.stats.pomodorosToday,
            skippedBreakCountToday: pomodoroService.stats.skippedBreaksToday,
            timeOfDay: TimeOfDay.from(now),
            codingStreakDays: pomodoroService.stats.streakDays
        )
    }
}
