//
//  SettingsDependencies.swift
//  Milo
//

import Foundation

@MainActor
final class SettingsDependencies {
    let reminderService: ReminderService?
    let todoService: TodoService?
    let pomodoroService: PomodoroService?
    let codingMetricsCoordinator: CodingMetricsCoordinator?
    let fileWatcherService: ProjectFileWatcherService?

    init(
        reminderService: ReminderService? = nil,
        todoService: TodoService? = nil,
        pomodoroService: PomodoroService? = nil,
        codingMetricsCoordinator: CodingMetricsCoordinator? = nil,
        fileWatcherService: ProjectFileWatcherService? = nil
    ) {
        self.reminderService = reminderService
        self.todoService = todoService
        self.pomodoroService = pomodoroService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.fileWatcherService = fileWatcherService
    }
}
