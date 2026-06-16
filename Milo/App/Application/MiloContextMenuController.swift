//
//  MiloContextMenuController.swift
//  Milo
//

import AppKit

@MainActor
final class MiloContextMenuController: NSObject, NSMenuDelegate {
    private let panelRouter: MiloPanelRouter
    private let miloStateStore: MiloStateStore
    private let pomodoroService: PomodoroService

    init(panelRouter: MiloPanelRouter, miloStateStore: MiloStateStore, pomodoroService: PomodoroService) {
        self.panelRouter = panelRouter
        self.miloStateStore = miloStateStore
        self.pomodoroService = pomodoroService
        super.init()
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu(title: "MILO")
        menu.delegate = self
        menu.autoenablesItems = false

        addSectionTitle("Quick Actions", to: menu)

        menu.addItem(makeItem(
            title: "Chat Reminder & Todo...",
            systemImage: "bubble.left.and.bubble.right.fill",
            action: #selector(openChatCommand)
        ))

        menu.addItem(makeItem(
            title: "Add Reminder...",
            systemImage: "bell.badge.fill",
            action: #selector(addReminder)
        ))

        menu.addItem(makeItem(
            title: "Add Todo...",
            systemImage: "checklist",
            action: #selector(addTodo)
        ))

        menu.addItem(.separator())

        addSectionTitle("Pomodoro Controls", to: menu)

        menu.addItem(makeItem(
            title: "Pause Pomodoro",
            systemImage: "pause.fill",
            action: #selector(pausePomodoro)
        ))

        menu.addItem(makeItem(
            title: "Resume Pomodoro",
            systemImage: "play.fill",
            action: #selector(resumePomodoro)
        ))

        menu.addItem(makeItem(
            title: "Reset Pomodoro",
            systemImage: "stop.fill",
            action: #selector(resetPomodoro)
        ))

        menu.addItem(makeItem(
            title: "Pomodoro Settings...",
            systemImage: "timer",
            action: #selector(openPomodoroSettings)
        ))

        menu.addItem(.separator())

        addSectionTitle("Productivity", to: menu)

        menu.addItem(makeItem(
            title: "Reminder History",
            systemImage: "clock.arrow.circlepath",
            action: #selector(openReminderHistory)
        ))

        menu.addItem(makeItem(
            title: "Todo List",
            systemImage: "list.bullet.clipboard",
            action: #selector(openTodoList)
        ))

        menu.addItem(.separator())

        addSectionTitle("Coding", to: menu)

        menu.addItem(makeItem(
            title: "Coding Metrics",
            systemImage: "chart.bar.xaxis",
            action: #selector(openCodingMetrics)
        ))

        menu.addItem(makeItem(
            title: "Weekly Coding Summary",
            systemImage: "calendar.badge.clock",
            action: #selector(openWeeklyCodingSummary)
        ))

        menu.addItem(.separator())

        menu.addItem(makeItem(
            title: "Settings...",
            systemImage: "gearshape.fill",
            action: #selector(openSettings)
        ))

        menu.addItem(makeItem(
            title: "Hide MILO",
            systemImage: "eye.slash.fill",
            action: #selector(hideMilo)
        ))

        return menu
    }

    private func addSectionTitle(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
    }

    private func makeItem(title: String, systemImage: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.image = NSImage(systemSymbolName: systemImage, accessibilityDescription: title)
        item.isEnabled = true
        return item
    }

    func menuWillOpen(_ menu: NSMenu) {
        print("MILO right click menu opened")
        miloStateStore.setContextMenuOpen(true)
    }

    func menuDidClose(_ menu: NSMenu) {
        print("MILO menu did close")
        miloStateStore.setContextMenuOpen(false)
    }

    @objc private func openChatCommand() {
        print("MILO menu item tapped: Chat Reminder & Todo")
        panelRouter.openChatCommand()
    }

    @objc private func addReminder() {
        print("MILO menu item tapped: Add Reminder")
        panelRouter.openAddReminder()
    }

    @objc private func addTodo() {
        print("MILO menu item tapped: Add Todo")
        panelRouter.openAddTodo()
    }

    @objc private func openReminderHistory() {
        print("MILO menu item tapped: Reminder History")
        panelRouter.openReminderHistory()
    }

    @objc private func pausePomodoro() {
        pomodoroService.pause()
    }

    @objc private func resumePomodoro() {
        pomodoroService.resume()
    }

    @objc private func resetPomodoro() {
        pomodoroService.reset()
    }

    @objc private func openPomodoroSettings() {
        panelRouter.openPomodoroSettings()
    }

    @objc private func openTodoList() {
        print("MILO menu item tapped: Todo List")
        panelRouter.openTodoList()
    }

    @objc private func openCodingMetrics() {
        print("MILO menu item tapped: Coding Metrics")
        panelRouter.openCodingMetrics()
    }

    @objc private func openWeeklyCodingSummary() {
        print("MILO menu item tapped: Weekly Coding Summary")
        panelRouter.openWeeklyCodingSummary()
    }

    @objc private func openSettings() {
        print("MILO menu item tapped: Settings")
        panelRouter.openSettings()
    }

    @objc private func hideMilo() {
        print("MILO menu item tapped: Hide MILO")
        panelRouter.hideMilo()
    }
}
