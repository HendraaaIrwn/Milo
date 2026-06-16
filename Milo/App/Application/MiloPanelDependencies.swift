//
//  MiloPanelDependencies.swift
//  Milo
//

import Foundation

@MainActor
final class MiloPanelDependencies {
    let miloStateStore: MiloStateStore
    let reminderService: ReminderService
    let reminderHistoryService: ReminderHistoryService
    let reminderSchedulerService: ReminderSchedulerService
    let todoService: TodoService
    let todoSchedulerService: TodoSchedulerService
    let pomodoroService: PomodoroService
    let codingMetricsCoordinator: CodingMetricsCoordinator
    let showBubble: (String) -> Void

    init(
        miloStateStore: MiloStateStore,
        reminderService: ReminderService,
        reminderHistoryService: ReminderHistoryService,
        reminderSchedulerService: ReminderSchedulerService,
        todoService: TodoService,
        todoSchedulerService: TodoSchedulerService,
        pomodoroService: PomodoroService,
        codingMetricsCoordinator: CodingMetricsCoordinator,
        showBubble: @escaping (String) -> Void
    ) {
        self.miloStateStore = miloStateStore
        self.reminderService = reminderService
        self.reminderHistoryService = reminderHistoryService
        self.reminderSchedulerService = reminderSchedulerService
        self.todoService = todoService
        self.todoSchedulerService = todoSchedulerService
        self.pomodoroService = pomodoroService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.showBubble = showBubble
    }
}
