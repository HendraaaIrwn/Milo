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
        let weeklyCodingMetricsService = WeeklyCodingMetricsService(storage: .shared)
        let codingMetricsCoordinator = CodingMetricsCoordinator(
            localMetricsService: codingMetricsService,
            weeklyMetricsService: weeklyCodingMetricsService,
            wakaTimeClient: WakaTimeClient()
        )

        let fileWatcherService = ProjectFileWatcherService(storage: .shared, bookmarkStore: .shared)
        self.projectFileWatcherService = fileWatcherService

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
            fileWatcherService: fileWatcherService
        )

        pomodoroService.onFocusCompleted = { [weak stateStore, weak miloWindowController] in
            stateStore?.animationState = .happy
            PomodoroSoundEngine.shared.playFocusComplete()
            miloWindowController?.showBubble("Focus complete. Break time unlocked.", mood: .happy)
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
            miloWindowController?.showBubble("Break done. Ready for another round?", mood: .idle)
        }

        self.miloWindowController = miloWindowController
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
            fileWatcherService: fileWatcherService
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
