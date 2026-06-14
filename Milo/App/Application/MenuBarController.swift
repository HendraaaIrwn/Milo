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
    private let reminderHistoryService: ReminderHistoryService
    private let reminderService: ReminderService
    private let todoService: TodoService
    private let codingMetricsCoordinator: CodingMetricsCoordinator

    private let pomodoroMenuItem = NSMenuItem()
    private var settingsWindow: NSWindow?
    private var todoWindow: NSWindow?

    init(
        miloWindowController: MiloWindowController,
        pomodoroService: PomodoroService,
        reminderHistoryService: ReminderHistoryService,
        reminderService: ReminderService,
        todoService: TodoService,
        codingMetricsCoordinator: CodingMetricsCoordinator
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.miloWindowController = miloWindowController
        self.pomodoroService = pomodoroService
        self.reminderHistoryService = reminderHistoryService
        self.reminderService = reminderService
        self.todoService = todoService
        self.codingMetricsCoordinator = codingMetricsCoordinator

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
        pomodoroMenuItem.submenu = makePomodoroMenu()
        menu.addItem(pomodoroMenuItem)
        menu.addItem(makeMenuItem(title: "Pomodoro Settings", action: #selector(openPomodoroSettings)))

        menu.addItem(makeMenuItem(title: "Add Reminder", action: #selector(addReminder)))
        menu.addItem(makeMenuItem(title: "Chat Reminder", action: #selector(chatReminder)))
        menu.addItem(makeMenuItem(title: "Reminder History", action: #selector(openReminderHistory)))
        menu.addItem(makeMenuItem(title: "Add Todo", action: #selector(addTodo)))
        menu.addItem(makeMenuItem(title: "Open Todos", action: #selector(openTodos)))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem(title: "Coding Metrics", action: #selector(openCodingMetrics)))
        menu.addItem(makeMenuItem(title: "Reset Local Coding Stats", action: #selector(resetCodingMetrics)))
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

    @objc private func startPomodoroShort() {
        startPomodoro(.short)
    }

    @objc private func startPomodoroMedium() {
        startPomodoro(.medium)
    }

    @objc private func startPomodoroLong() {
        startPomodoro(.long)
    }

    @objc private func pausePomodoro() {
        pomodoroService.pause()
        updatePomodoroMenuTitle()
    }

    @objc private func resumePomodoro() {
        pomodoroService.resume()
        updatePomodoroMenuTitle()
    }

    @objc private func resetPomodoro() {
        pomodoroService.reset()
        updatePomodoroMenuTitle()
    }

    @objc private func openPomodoroSettings() {
        miloWindowController.openPomodoroSettings()
    }

    private func startPomodoro(_ preset: PomodoroPreset) {
        pomodoroService.start(preset: preset)
        miloWindowController.showBubble("Pomodoro started. Let’s focus.", mood: .focus)
        updatePomodoroMenuTitle()
    }

    @objc private func addReminder() {
        miloWindowController.openReminderEntry(source: .menuBar)
    }

    @objc private func chatReminder() {
        miloWindowController.openChatReminder()
    }

    @objc private func openReminderHistory() {
        miloWindowController.openReminderHistory()
    }

    @objc private func addTodo() {
        miloWindowController.openTodoEditor()
    }

    @objc private func openSettings() {
        let window = settingsWindow ?? makeSettingsWindow()
        settingsWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func openTodos() {
        miloWindowController.openTodoList()
    }

    @objc private func openCodingMetrics() {
        miloWindowController.openCodingMetricsPanel()
    }

    @objc private func resetCodingMetrics() {
        codingMetricsCoordinator.localMetricsService.resetLocalStats()
    }

    @objc private func quitApp() {
        reminderService.save()
        reminderHistoryService.save()
        todoService.save()
        pomodoroService.stop()
        reminderService.closeEntryWindow()
        miloWindowController.close()
        NSApplication.shared.terminate(nil)
    }

    private func updatePomodoroMenuTitle() {
        if pomodoroService.isRunning, pomodoroService.isPaused {
            pomodoroMenuItem.title = "Pomodoro Paused"
        } else if pomodoroService.isRunning {
            pomodoroMenuItem.title = "Pomodoro Running"
        } else {
            pomodoroMenuItem.title = "Start Pomodoro"
        }
        pomodoroMenuItem.submenu = makePomodoroMenu()
    }

    private func makePomodoroMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(makeMenuItem(title: "25/5", action: #selector(startPomodoroShort)))
        menu.addItem(makeMenuItem(title: "50/10", action: #selector(startPomodoroMedium)))
        menu.addItem(makeMenuItem(title: "90/15", action: #selector(startPomodoroLong)))
        menu.addItem(makeMenuItem(title: "Custom...", action: #selector(openPomodoroSettings)))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem(title: "Pause", action: #selector(pausePomodoro)))
        menu.addItem(makeMenuItem(title: "Resume", action: #selector(resumePomodoro)))
        menu.addItem(makeMenuItem(title: "Reset", action: #selector(resetPomodoro)))
        return menu
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
        window.contentViewController = NSHostingController(rootView: SettingsView(pomodoroService: pomodoroService))
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
        window.contentViewController = NSHostingController(rootView: TodoListView(
            todoService: todoService,
            onEditTodo: { [weak self, weak window] todo in
                self?.miloWindowController.openTodoEditor(existingTodo: todo)
                window?.close()
            },
            onConvertToReminder: { [weak self, weak window] todo in
                guard let dueDate = todo.dueDate else {
                    self?.miloWindowController.openTodoEditor(existingTodo: todo)
                    return
                }
                let reminder = self?.reminderService ?? ReminderService()
                let _ = reminder.addReminder(title: todo.title, message: todo.title, dueDate: dueDate, createdSource: .todo)
                window?.close()
            }
        ))
        return window
    }
}
