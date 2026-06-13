//
//  MenuBarController.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let miloWindowController: MiloWindowController
    private let pomodoroService: PomodoroService
    private let reminderService: ReminderService
    private let todoService: TodoService

    private let pomodoroMenuItem = NSMenuItem()
    private var settingsWindow: NSWindow?
    private var todoWindow: NSWindow?

    init(
        miloWindowController: MiloWindowController,
        pomodoroService: PomodoroService,
        reminderService: ReminderService,
        todoService: TodoService
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.miloWindowController = miloWindowController
        self.pomodoroService = pomodoroService
        self.reminderService = reminderService
        self.todoService = todoService

        super.init()
        setupStatusItem()
        setupMenu()
    }

    func cleanup() {
        settingsWindow?.close()
        settingsWindow = nil
        todoWindow?.close()
        todoWindow = nil
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }

        if let image = NSImage(systemSymbolName: "apple.terminal.fill", accessibilityDescription: "MILO") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "MILO"
        }
    }

    private func setupMenu() {
        let menu = NSMenu()

        menu.addItem(makeMenuItem(title: "Show Milo", action: #selector(showMilo)))
        menu.addItem(makeMenuItem(title: "Hide Milo", action: #selector(hideMilo)))
        menu.addItem(.separator())

        pomodoroMenuItem.title = "Start Pomodoro"
        pomodoroMenuItem.target = self
        pomodoroMenuItem.action = #selector(togglePomodoro)
        menu.addItem(pomodoroMenuItem)

        menu.addItem(makeMenuItem(title: "Add Reminder", action: #selector(addReminder)))
        menu.addItem(makeMenuItem(title: "Open Todos", action: #selector(openTodos)))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem(title: "Settings", action: #selector(openSettings)))
        menu.addItem(makeMenuItem(title: "Quit", action: #selector(quitApp)))

        statusItem.menu = menu
    }

    private func makeMenuItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    @objc private func showMilo() {
        miloWindowController.showMilo()
    }

    @objc private func hideMilo() {
        miloWindowController.hideMilo()
    }

    @objc private func togglePomodoro() {
        if pomodoroService.isRunning, !pomodoroService.isPaused {
            pomodoroService.pause()
            updatePomodoroMenuTitle()
            return
        }

        if pomodoroService.isRunning, pomodoroService.isPaused {
            pomodoroService.resume()
        } else {
            pomodoroService.startDefaultPomodoro()
        }

        miloWindowController.showBubble("Pomodoro started. Let’s focus.", mood: .focus)
        updatePomodoroMenuTitle()
    }

    @objc private func addReminder() {
        miloWindowController.openReminderEntry(source: .menuBar)
    }

    @objc private func openSettings() {
        let window = settingsWindow ?? makeSettingsWindow()
        settingsWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func openTodos() {
        let window = todoWindow ?? makeTodoWindow()
        todoWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func quitApp() {
        reminderService.save()
        todoService.save()
        pomodoroService.stop()
        reminderService.closeEntryWindow()
        miloWindowController.close()
        NSApplication.shared.terminate(nil)
    }

    private func updatePomodoroMenuTitle() {
        if pomodoroService.isRunning, !pomodoroService.isPaused {
            pomodoroMenuItem.title = "Pause Pomodoro"
        } else {
            pomodoroMenuItem.title = "Start Pomodoro"
        }
    }

    private func makeSettingsWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Settings"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(rootView: SettingsView())
        return window
    }

    private func makeTodoWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Todos"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(rootView: TodoListView(todoService: todoService))
        return window
    }
}
