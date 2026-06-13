//
//  AppDelegate.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var miloWindowController: MiloWindowController?
    private var pomodoroService: PomodoroService?
    private var reminderService: ReminderService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let miloWindowController = MiloWindowController()
        let pomodoroService = PomodoroService()
        let reminderService = ReminderService()

        self.miloWindowController = miloWindowController
        self.pomodoroService = pomodoroService
        self.reminderService = reminderService
        self.menuBarController = MenuBarController(
            miloWindowController: miloWindowController,
            pomodoroService: pomodoroService,
            reminderService: reminderService
        )

        if UserDefaults.standard.object(forKey: MiloSettingsKeys.showMiloOnLaunch) as? Bool ?? true {
            miloWindowController.showMilo()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        pomodoroService?.stop()
        reminderService?.closeEntryWindow()
        miloWindowController?.close()
        menuBarController?.cleanup()
    }
}
