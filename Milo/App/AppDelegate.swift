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
    private var reminderService: ReminderService?
    private var reminderSchedulerService: ReminderSchedulerService?
    private var todoService: TodoService?

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
        let reminderService = ReminderService()
        let todoService = TodoService()
        let reminderSchedulerService = ReminderSchedulerService(
            reminderService: reminderService,
            miloStateStore: stateStore
        )
        let miloWindowController = MiloWindowController(
            stateStore: stateStore,
            reminderService: reminderService,
            reminderSchedulerService: reminderSchedulerService
        )

        self.miloWindowController = miloWindowController
        self.pomodoroService = pomodoroService
        self.reminderService = reminderService
        self.reminderSchedulerService = reminderSchedulerService
        self.todoService = todoService
        self.menuBarController = MenuBarController(
            miloWindowController: miloWindowController,
            pomodoroService: pomodoroService,
            reminderService: reminderService,
            todoService: todoService
        )

        ReminderNotificationService.shared.requestAuthorizationIfNeeded()
        reminderSchedulerService.reschedulePendingNotifications()
        reminderSchedulerService.start()

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
        reminderSchedulerService?.stop()
        reminderService?.save()
        todoService?.save()
        pomodoroService?.stop()
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
