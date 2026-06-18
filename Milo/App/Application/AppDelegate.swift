//
//  AppDelegate.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var miloWindowController: MiloWindowController?
    private var pomodoroService: PomodoroService?
    private var reminderHistoryService: ReminderHistoryService?
    private var reminderService: ReminderService?
    private var reminderSchedulerService: ReminderSchedulerService?
    private var todoService: TodoService?
    private var todoSchedulerService: TodoSchedulerService?
    private var codingMetricsService: CodingMetricsService?
    private var codingMetricsCoordinator: CodingMetricsCoordinator?
    private var projectFileWatcherService: ProjectFileWatcherService?
    private var personalitySettingsStore: MiloPersonalitySettingsStore?
    private var availabilityService: AppleIntelligenceAvailabilityService?
    private var perAgentManager: MiloPerAgentIntegrationManager?
    private var agentSettingsStore: MiloAgentIntegrationsSettingsStore?
    private var claudeCodeIntegration: MiloClaudeCodeIntegration?
    private var claudeCodeIntegrationBundleURL: URL?

    private(set) var miloStateStore: MiloStateStore?
    private var keyboardActivityService: KeyboardActivityService?
    private var typingBubbleService: TypingBubbleService?
    private var typingReactionCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let stateStore = MiloStateStore()
        self.miloStateStore = stateStore

        let typingBubbleService = TypingBubbleService(miloStateStore: stateStore)
        self.typingBubbleService = typingBubbleService

        let keyboardService = KeyboardActivityService(
            miloStateStore: stateStore,
            typingBubbleService: typingBubbleService
        )
        self.keyboardActivityService = keyboardService

        let pomodoroService = PomodoroService()
        let reminderHistoryService = ReminderHistoryService()
        let reminderService = ReminderService(historyService: reminderHistoryService)
        let todoService = TodoService()
        let reminderSchedulerService = ReminderSchedulerService(
            reminderService: reminderService,
            historyService: reminderHistoryService,
            miloStateStore: stateStore
        )
        let todoSchedulerService = TodoSchedulerService(
            todoService: todoService,
            miloStateStore: stateStore
        )
        let codingMetricsService = CodingMetricsService(storage: .shared)
        let weeklyCodingMetricsService = WeeklyCodingMetricsService(
            storage: .shared,
            pomodoroService: pomodoroService,
            todoService: todoService
        )
        let codingMetricsCoordinator = CodingMetricsCoordinator(
            localMetricsService: codingMetricsService,
            weeklyMetricsService: weeklyCodingMetricsService,
            wakaTimeClient: WakaTimeClient()
        )

        let fileWatcherService = ProjectFileWatcherService(storage: .shared, bookmarkStore: .shared)
        self.projectFileWatcherService = fileWatcherService

        let personalitySettingsStore = MiloPersonalitySettingsStore()
        self.personalitySettingsStore = personalitySettingsStore

        let availabilityService = AppleIntelligenceAvailabilityService()
        self.availabilityService = availabilityService

        let aiGenerator = AppleFoundationModelsResponseGenerator()

        let agentIntegrationsStore = MiloAgentIntegrationsSettingsStore()
        self.agentSettingsStore = agentIntegrationsStore

        let agentDetectionStore = MiloAgentDetectionSettingsStore()
        let agentStatusStore = MiloAgentStatusStore()

        if agentDetectionStore.settings.isEnabled {
            var s = agentDetectionStore.settings
            s.isEnabled = false
            s.isConnected = false
            s.autoStartOnLaunch = false
            agentDetectionStore.settings = s
        }

        let agentDetector = MiloAgentDetector(
            statusStore: agentStatusStore,
            settingsStore: agentIntegrationsStore
        )

        let testService = MiloAgentConnectionTestService()
        let agentPreflight = MiloAgentIntegrationPreflightService()
        let perAgentManager = MiloPerAgentIntegrationManager(
            settingsStore: agentIntegrationsStore,
            detector: agentDetector,
            statusStore: agentStatusStore,
            testService: testService
        )
        self.perAgentManager = perAgentManager

        // The Claude Code facade is constructed lazily inside the window
        // controller because it needs the overlay coordinator and the
        // floating pet state. We hold a back-reference here so we can stop
        // it cleanly on terminate.
        let miloctlBundleURL = Bundle.main.url(forResource: "miloctl", withExtension: nil)
        self.claudeCodeIntegrationBundleURL = miloctlBundleURL

        fileWatcherService.onProjectActivity = { [weak codingMetricsService] activitySnapshot in
            Task { @MainActor in
                codingMetricsService?.applyProjectActivitySnapshot(activitySnapshot)
            }
        }

        let miloWindowController = MiloWindowController(
            stateStore: stateStore,
            reminderService: reminderService,
            reminderHistoryService: reminderHistoryService,
            reminderSchedulerService: reminderSchedulerService,
            todoService: todoService,
            todoSchedulerService: todoSchedulerService,
            pomodoroService: pomodoroService,
            codingMetricsCoordinator: codingMetricsCoordinator,
            fileWatcherService: fileWatcherService,
            personalitySettingsStore: personalitySettingsStore,
            availabilityService: availabilityService,
            aiGenerator: aiGenerator,
            perAgentManager: perAgentManager,
            agentSettingsStore: agentIntegrationsStore,
            agentDetectionStore: agentDetectionStore,
            claudeCodeIntegrationBundleURL: miloctlBundleURL,
            agentStatusStore: agentStatusStore
        )

        pomodoroService.onFocusCompleted = { [weak stateStore, weak miloWindowController] in
            stateStore?.animationState = .happy
            PomodoroSoundEngine.shared.playFocusComplete()
            miloWindowController?.handlePomodoroCompleted()
        }

        pomodoroService.onFocusStarted = {
            PomodoroSoundEngine.shared.playFocusStart()
        }

        pomodoroService.onBreakStarted = { [weak stateStore] in
            stateStore?.animationState = .breakTime
        }

        pomodoroService.onBreakCompleted = { [weak stateStore, weak miloWindowController] in
            stateStore?.animationState = .idle
            PomodoroSoundEngine.shared.playBreakComplete()
            miloWindowController?.handleBreakCompleted()
        }

        self.miloWindowController = miloWindowController
        self.claudeCodeIntegration = miloWindowController.claudeCodeIntegrationFacade
        perAgentManager.onAgentConnected = { [weak self] agentType in
            guard agentType == .claudeCode || agentType == .codex else { return }
            self?.claudeCodeIntegration?.start()
        }
        perAgentManager.onAgentDisconnected = { [weak self] agentType in
            guard agentType == .claudeCode || agentType == .codex else { return }
            let codexConnected = agentIntegrationsStore.config(for: .codex).isConnected
            let claudeConnected = agentIntegrationsStore.config(for: .claudeCode).isConnected
            guard !codexConnected && !claudeConnected else { return }
            self?.claudeCodeIntegration?.stop()
        }
        self.pomodoroService = pomodoroService
        self.reminderHistoryService = reminderHistoryService
        self.reminderService = reminderService
        self.reminderSchedulerService = reminderSchedulerService
        self.todoSchedulerService = todoSchedulerService
        self.todoService = todoService
        self.codingMetricsService = codingMetricsService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.menuBarController = MenuBarController(
            miloWindowController: miloWindowController,
            panelRouter: miloWindowController.panelRouter,
            pomodoroService: pomodoroService,
            reminderHistoryService: reminderHistoryService,
            reminderService: reminderService,
            todoService: todoService,
            codingMetricsCoordinator: codingMetricsCoordinator,
            fileWatcherService: fileWatcherService,
            agentSettingsStore: agentIntegrationsStore
        )

        ReminderNotificationService.shared.requestAuthorizationIfNeeded()
        reminderSchedulerService.reschedulePendingNotifications()
        reminderSchedulerService.start()
        todoSchedulerService.start()
        codingMetricsCoordinator.start()
        fileWatcherService.start()

        if UserDefaults.standard.object(forKey: MiloSettingsKeys.showMiloOnLaunch) as? Bool ?? true {
            miloWindowController.showMilo()
        }

        if UserDefaults.standard.object(forKey: MiloSettingsKeys.typingReaction) as? Bool ?? true {
            keyboardService.start()
        }

        observeTypingReaction()
    }


    func applicationDidBecomeActive(_ notification: Notification) {
        restartKeyboardMonitorIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        MiloMumbleEngine.shared.stop()
        keyboardActivityService?.stop()
        todoSchedulerService?.stop()
        reminderSchedulerService?.stop()
        codingMetricsCoordinator?.stop()
        codingMetricsService?.save()
        projectFileWatcherService?.stop()
        reminderHistoryService?.save()
        reminderService?.save()
        todoService?.save()
        todoSchedulerService?.stop()
        pomodoroService?.save()
        reminderService?.closeEntryWindow()
        miloWindowController?.close()
        menuBarController?.cleanup()
        claudeCodeIntegration?.stop()
    }


    private func restartKeyboardMonitorIfNeeded() {
        let enabled = UserDefaults.standard.object(forKey: MiloSettingsKeys.typingReaction) as? Bool ?? true
        guard enabled else { return }
        keyboardActivityService?.start()
    }

    private func observeTypingReaction() {
        typingReactionCancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    let enabled = UserDefaults.standard.object(forKey: MiloSettingsKeys.typingReaction) as? Bool ?? true
                    if enabled {
                        self.keyboardActivityService?.start()
                    } else {
                        self.keyboardActivityService?.stop()
                        self.typingBubbleService?.handleTypingStopped()
                        self.miloStateStore?.setIdle()
                    }

                    let bubbleEnabled = UserDefaults.standard.object(forKey: MiloSettingsKeys.typingBubbleDialogs) as? Bool ?? true
                    if !bubbleEnabled {
                        self.typingBubbleService?.handleTypingBubbleDisabled()
                    }
                }
            }
    }
}
