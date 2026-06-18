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
    let agentIntegrationsSettingsStore: MiloAgentIntegrationsSettingsStore?
    let perAgentManager: MiloPerAgentIntegrationManager?
    let claudeCodeIntegration: MiloClaudeCodeIntegration?

    init(
        reminderService: ReminderService? = nil,
        todoService: TodoService? = nil,
        pomodoroService: PomodoroService? = nil,
        codingMetricsCoordinator: CodingMetricsCoordinator? = nil,
        fileWatcherService: ProjectFileWatcherService? = nil,
        personalitySettingsStore: MiloPersonalitySettingsStore? = nil,
        availabilityService: AppleIntelligenceAvailabilityService? = nil,
        onTestSmartPersonality: (() async -> String?)? = nil,
        agentIntegrationsSettingsStore: MiloAgentIntegrationsSettingsStore? = nil,
        perAgentManager: MiloPerAgentIntegrationManager? = nil,
        claudeCodeIntegration: MiloClaudeCodeIntegration? = nil
    ) {
        self.reminderService = reminderService
        self.todoService = todoService
        self.pomodoroService = pomodoroService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.fileWatcherService = fileWatcherService
        self.personalitySettingsStore = personalitySettingsStore
        self.availabilityService = availabilityService
        self.onTestSmartPersonality = onTestSmartPersonality
        self.agentIntegrationsSettingsStore = agentIntegrationsSettingsStore
        self.perAgentManager = perAgentManager
        self.claudeCodeIntegration = claudeCodeIntegration
    }
}
