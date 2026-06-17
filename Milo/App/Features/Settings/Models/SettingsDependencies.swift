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
    let personalitySettingsStore: MiloPersonalitySettingsStore?
    let availabilityService: AppleIntelligenceAvailabilityService?
    let onTestSmartPersonality: (() async -> String?)?

    init(
        reminderService: ReminderService? = nil,
        todoService: TodoService? = nil,
        pomodoroService: PomodoroService? = nil,
        codingMetricsCoordinator: CodingMetricsCoordinator? = nil,
        fileWatcherService: ProjectFileWatcherService? = nil,
        personalitySettingsStore: MiloPersonalitySettingsStore? = nil,
        availabilityService: AppleIntelligenceAvailabilityService? = nil,
        onTestSmartPersonality: (() async -> String?)? = nil
    ) {
        self.reminderService = reminderService
        self.todoService = todoService
        self.pomodoroService = pomodoroService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.fileWatcherService = fileWatcherService
        self.personalitySettingsStore = personalitySettingsStore
        self.availabilityService = availabilityService
        self.onTestSmartPersonality = onTestSmartPersonality
    }
}
