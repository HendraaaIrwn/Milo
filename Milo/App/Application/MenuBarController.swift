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
    private let panelRouter: MiloPanelRouter
    private let pomodoroService: PomodoroService
    private let reminderHistoryService: ReminderHistoryService
    private let reminderService: ReminderService
    private let todoService: TodoService
    private let codingMetricsCoordinator: CodingMetricsCoordinator
    private let fileWatcherService: ProjectFileWatcherService
    private let sparkleUpdaterController: SparkleUpdaterController

    private let pomodoroMenuItem = NSMenuItem()

    init(
        miloWindowController: MiloWindowController,
        panelRouter: MiloPanelRouter,
        pomodoroService: PomodoroService,
        reminderHistoryService: ReminderHistoryService,
        reminderService: ReminderService,
        todoService: TodoService,
        codingMetricsCoordinator: CodingMetricsCoordinator,
        fileWatcherService: ProjectFileWatcherService,
        sparkleUpdaterController: SparkleUpdaterController
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.miloWindowController = miloWindowController
        self.panelRouter = panelRouter
        self.pomodoroService = pomodoroService
        self.reminderHistoryService = reminderHistoryService
        self.reminderService = reminderService
        self.todoService = todoService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.fileWatcherService = fileWatcherService
        self.sparkleUpdaterController = sparkleUpdaterController

        super.init()
        setupStatusItem()
        statusItem.menu = buildMenu()
    }

    func cleanup() {
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }
        if let image = NSImage(systemSymbolName: "apple.terminal.fill", accessibilityDescription: "MILO") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "MILO"
        }
    }

    // MARK: - Menu Builder

    private func buildMenu() -> NSMenu {
        let menu = NSMenu(title: "MILO")

        addQuickActionsSection(to: menu)
        menu.addItem(.separator())

        addProductivitySection(to: menu)
        menu.addItem(.separator())

        addCodingSection(to: menu)
        menu.addItem(.separator())

        addSystemSection(to: menu)

        return menu
    }

    // MARK: - Quick Actions

    private func addQuickActionsSection(to menu: NSMenu) {
        addSectionTitle("Quick Actions", to: menu)

        menu.addItem(makeItem(
            "Chat Reminder & Todo...",
            icon: "bubble.left.and.bubble.right.fill",
            action: #selector(chatReminder)
        ))

        menu.addItem(makeItem(
            "Add Reminder...",
            icon: "bell.badge.fill",
            action: #selector(addReminder)
        ))

        menu.addItem(makeItem(
            "Add Todo...",
            icon: "checklist",
            action: #selector(addTodo)
        ))

        pomodoroMenuItem.title = "Start Pomodoro"
        pomodoroMenuItem.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro")
        pomodoroMenuItem.submenu = makePomodoroMenu()
        menu.addItem(pomodoroMenuItem)
    }

    // MARK: - Productivity

    private func addProductivitySection(to menu: NSMenu) {
        addSectionTitle("Productivity", to: menu)

        menu.addItem(makeItem(
            "Reminder History",
            icon: "clock.arrow.circlepath",
            action: #selector(openReminderHistory)
        ))

        menu.addItem(makeItem(
            "Todo List",
            icon: "list.bullet.clipboard",
            action: #selector(openTodos)
        ))
    }

    // MARK: - Coding

    private func addCodingSection(to menu: NSMenu) {
        addSectionTitle("Coding", to: menu)

        menu.addItem(makeItem(
            "Coding Metrics",
            icon: "chart.bar.xaxis",
            action: #selector(openCodingMetrics)
        ))

        menu.addItem(makeItem(
            "Weekly Coding Summary",
            icon: "calendar.badge.clock",
            action: #selector(openWeeklyCodingSummary)
        ))

        menu.addItem(makeItem(
            "File Watcher Settings",
            icon: "folder.badge.gearshape",
            action: #selector(openFileWatcherSettings)
        ))

        menu.addItem(makeItem(
            "Reset Local Coding Stats",
            icon: "arrow.counterclockwise.circle",
            action: #selector(resetCodingMetrics)
        ))
    }

    // MARK: - System

    private func addSystemSection(to menu: NSMenu) {
        addSectionTitle("System", to: menu)

        menu.addItem(makeItem(
            "Show MILO",
            icon: "eye.fill",
            action: #selector(showMilo)
        ))

        menu.addItem(makeItem(
            "Hide MILO",
            icon: "eye.slash.fill",
            action: #selector(hideMilo)
        ))

        menu.addItem(makeItem(
            "Settings...",
            icon: "gearshape.fill",
            action: #selector(openSettings)
        ))

        menu.addItem(makeItem(
            "Check for Updates...",
            icon: "arrow.down.circle",
            action: #selector(checkForUpdates)
        ))

        menu.addItem(makeItem(
            "Quit",
            icon: "power",
            action: #selector(quitApp)
        ))
    }

    // MARK: - Helpers

    private func addSectionTitle(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title.uppercased(), action: nil, keyEquivalent: "")
        item.isEnabled = false

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: NSColor.tertiaryLabelColor,
            .paragraphStyle: paragraph
        ]

        item.attributedTitle = NSAttributedString(string: title.uppercased(), attributes: attributes)
        menu.addItem(item)
    }

    private func makeItem(_ title: String, icon: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.image = NSImage(systemSymbolName: icon, accessibilityDescription: title)
        return item
    }

    // MARK: - Actions

    @objc private func showMilo() { miloWindowController.showMilo() }
    @objc private func hideMilo() { miloWindowController.hideMilo() }

    private func startPomodoro(_ preset: PomodoroPreset) {
        pomodoroService.start(preset: preset)
        updatePomodoroMenuTitle()
    }

    @objc private func startPomodoroShort() { startPomodoro(.short) }
    @objc private func startPomodoroMedium() { startPomodoro(.medium) }
    @objc private func startPomodoroLong() { startPomodoro(.long) }
    @objc private func openPomodoroSettings() { panelRouter.openPomodoroSettings() }
    @objc private func pausePomodoro() { pomodoroService.pause(); updatePomodoroMenuTitle() }
    @objc private func resumePomodoro() { pomodoroService.resume(); updatePomodoroMenuTitle() }
    @objc private func resetPomodoro() { pomodoroService.reset(); updatePomodoroMenuTitle() }

    @objc private func openSettings() { miloWindowController.openSettings() }
    @objc private func checkForUpdates() { sparkleUpdaterController.checkForUpdates() }

    // Routed through panel router for consistent UI
    @objc private func addReminder() { panelRouter.openAddReminder() }
    @objc private func chatReminder() { panelRouter.openChatCommand() }
    @objc private func openReminderHistory() { panelRouter.openReminderHistory() }
    @objc private func addTodo() { panelRouter.openAddTodo() }
    @objc private func openTodos() { panelRouter.openTodoList() }
    @objc private func openCodingMetrics() { panelRouter.openCodingMetrics() }
    @objc private func openWeeklyCodingSummary() { panelRouter.openWeeklyCodingSummary() }
    @objc private func openFileWatcherSettings() { miloWindowController.openFileWatcherSettings() }
    @objc private func resetCodingMetrics() { codingMetricsCoordinator.localMetricsService.resetLocalStats() }

    @objc private func quitApp() {
        reminderService.save()
        reminderHistoryService.save()
        todoService.save()
        pomodoroService.stop()
        reminderService.closeEntryWindow()
        miloWindowController.close()
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Pomodoro Submenu

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
        menu.addItem(makeMenuItem("25/5", #selector(startPomodoroShort)))
        menu.addItem(makeMenuItem("50/10", #selector(startPomodoroMedium)))
        menu.addItem(makeMenuItem("90/15", #selector(startPomodoroLong)))
        menu.addItem(makeMenuItem("Custom...", #selector(openPomodoroSettings)))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem("Pause", #selector(pausePomodoro)))
        menu.addItem(makeMenuItem("Resume", #selector(resumePomodoro)))
        menu.addItem(makeMenuItem("Reset", #selector(resetPomodoro)))
        return menu
    }

    private func makeMenuItem(_ title: String, _ action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }
}
