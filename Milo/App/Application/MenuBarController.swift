//
//  MenuBarController.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let miloWindowController: MiloWindowController
    private let panelRouter: MiloPanelRouter
    private let pomodoroService: PomodoroService
    private let reminderHistoryService: ReminderHistoryService
    private let reminderService: ReminderService
    private let todoService: TodoService
    private let codingMetricsCoordinator: CodingMetricsCoordinator
    private let fileWatcherService: ProjectFileWatcherService
    private let agentSettingsStore: MiloAgentIntegrationsSettingsStore

    private var isMenuTracking = false
    private var cancellables = Set<AnyCancellable>()

    private let pomodoroMenuItem = NSMenuItem()
    private var pomodoroPauseItem: NSMenuItem!
    private var pomodoroResumeItem: NSMenuItem!
    private var pomodoroResetItem: NSMenuItem!
    private var agentDetectionToggleItem: NSMenuItem!

    init(
        miloWindowController: MiloWindowController,
        panelRouter: MiloPanelRouter,
        pomodoroService: PomodoroService,
        reminderHistoryService: ReminderHistoryService,
        reminderService: ReminderService,
        todoService: TodoService,
        codingMetricsCoordinator: CodingMetricsCoordinator,
        fileWatcherService: ProjectFileWatcherService,
        agentSettingsStore: MiloAgentIntegrationsSettingsStore
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
        self.agentSettingsStore = agentSettingsStore

        super.init()
        setupStatusItem()
        statusItem.menu = buildMenuOnce()
        observePomodoroState()
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

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        isMenuTracking = true
        updateCachedMenuState()
    }

    func menuDidClose(_ menu: NSMenu) {
        isMenuTracking = false
    }

    // MARK: - Menu Builder (called once)

    private func buildMenuOnce() -> NSMenu {
        let menu = NSMenu(title: "MILO")
        menu.delegate = self

        addQuickActionsSection(to: menu)
        menu.addItem(.separator())

        addProductivitySection(to: menu)
        menu.addItem(.separator())

        addCodingSection(to: menu)
        menu.addItem(.separator())

        addAgentSection(to: menu)
        menu.addItem(.separator())

        addSystemSection(to: menu)

        return menu
    }

    private func updateCachedMenuState() {
        updatePomodoroMenuState()
        updateAgentMenuState()
    }

    // MARK: - Quick Actions

    private func addQuickActionsSection(to menu: NSMenu) {
        addSectionTitle("Quick Actions", to: menu)

        menu.addItem(makeItem("Chat Reminder & Todo...", icon: "bubble.left.and.bubble.right.fill", action: #selector(chatReminder)))
        menu.addItem(makeItem("Add Reminder...", icon: "bell.badge.fill", action: #selector(addReminder)))
        menu.addItem(makeItem("Add Todo...", icon: "checklist", action: #selector(addTodo)))

        pomodoroMenuItem.title = "Start Pomodoro"
        pomodoroMenuItem.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro")
        pomodoroMenuItem.submenu = makePomodoroSubmenu()
        menu.addItem(pomodoroMenuItem)
    }

    // MARK: - Productivity

    private func addProductivitySection(to menu: NSMenu) {
        addSectionTitle("Productivity", to: menu)
        menu.addItem(makeItem("Reminder History", icon: "clock.arrow.circlepath", action: #selector(openReminderHistory)))
        menu.addItem(makeItem("Todo List", icon: "list.bullet.clipboard", action: #selector(openTodos)))
    }

    // MARK: - Coding

    private func addCodingSection(to menu: NSMenu) {
        addSectionTitle("Coding", to: menu)
        menu.addItem(makeItem("Coding Metrics", icon: "chart.bar.xaxis", action: #selector(openCodingMetrics)))
        menu.addItem(makeItem("Weekly Coding Summary", icon: "calendar.badge.clock", action: #selector(openWeeklyCodingSummary)))
        menu.addItem(makeItem("File Watcher Settings", icon: "folder.badge.gearshape", action: #selector(openFileWatcherSettings)))
        menu.addItem(makeItem("Reset Local Coding Stats", icon: "arrow.counterclockwise.circle", action: #selector(resetCodingMetrics)))
    }

    // MARK: - Agent

    private func addAgentSection(to menu: NSMenu) {
        addSectionTitle("Agent", to: menu)

        let statusItem = NSMenuItem(
            title: "Connected: 0 agents",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false
        statusItem.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "Agent")
        menu.addItem(statusItem)
        agentDetectionToggleItem = statusItem

        menu.addItem(makeItem("Agent Integrations...", icon: "gearshape.fill", action: #selector(openAgentIntegrations)))
    }

    private func updateAgentMenuState() {
        let connected = agentSettingsStore.configs.filter { $0.isConnected }.count
        let total = agentSettingsStore.configs.count
        agentDetectionToggleItem.title = "Connected: \(connected) / \(total)"
    }

    @objc private func openAgentIntegrations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.miloWindowController.openSettings()
        }
    }

    // MARK: - System

    private func addSystemSection(to menu: NSMenu) {
        addSectionTitle("System", to: menu)
        menu.addItem(makeItem("Show MILO", icon: "eye.fill", action: #selector(showMilo)))
        menu.addItem(makeItem("Hide MILO", icon: "eye.slash.fill", action: #selector(hideMilo)))
        menu.addItem(makeItem("Settings...", icon: "gearshape.fill", action: #selector(openSettings)))
        menu.addItem(makeItem("Quit", icon: "power", action: #selector(quitApp)))
    }

    // MARK: - Helpers

    private func addSectionTitle(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title.uppercased(), action: nil, keyEquivalent: "")
        item.isEnabled = false
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        item.attributedTitle = NSAttributedString(
            string: title.uppercased(),
            attributes: [
                .font: NSFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: NSColor.tertiaryLabelColor,
                .paragraphStyle: paragraph
            ]
        )
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
        updatePomodoroMenuState()
    }

    @objc private func startPomodoroShort() { startPomodoro(.short) }
    @objc private func startPomodoroMedium() { startPomodoro(.medium) }
    @objc private func startPomodoroLong() { startPomodoro(.long) }
    @objc private func openPomodoroSettings() { panelRouter.openPomodoroSettings() }
    @objc private func pausePomodoro() { pomodoroService.pause(); updatePomodoroMenuState() }
    @objc private func resumePomodoro() { pomodoroService.resume(); updatePomodoroMenuState() }
    @objc private func resetPomodoro() { pomodoroService.reset(); updatePomodoroMenuState() }

    @objc private func openSettings() { miloWindowController.openSettings() }

    @objc private func addReminder() { panelRouter.openAddReminder() }
    @objc private func chatReminder() { panelRouter.openChatCommand() }
    @objc private func openReminderHistory() { panelRouter.openReminderHistory() }
    @objc private func addTodo() { panelRouter.openAddTodo() }
    @objc private func openTodos() { panelRouter.openTodoList() }

    @objc private func openCodingMetrics() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.panelRouter.openCodingMetrics()
        }
    }

    @objc private func openWeeklyCodingSummary() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.panelRouter.openWeeklyCodingSummary()
        }
    }

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

    private func observePomodoroState() {
        pomodoroService.$session
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, !self.isMenuTracking else { return }
                    self.updatePomodoroMenuState()
                }
            }
            .store(in: &cancellables)
    }

    private func updatePomodoroMenuState() {
        if pomodoroService.isRunning, pomodoroService.isPaused {
            pomodoroMenuItem.title = "Pomodoro Paused"
        } else if pomodoroService.isRunning {
            pomodoroMenuItem.title = "Pomodoro Running"
        } else {
            pomodoroMenuItem.title = "Start Pomodoro"
        }
    }

    private func makePomodoroSubmenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(makePomodoroSubItem("25/5", #selector(startPomodoroShort)))
        menu.addItem(makePomodoroSubItem("50/10", #selector(startPomodoroMedium)))
        menu.addItem(makePomodoroSubItem("90/15", #selector(startPomodoroLong)))
        menu.addItem(makePomodoroSubItem("Custom...", #selector(openPomodoroSettings)))
        menu.addItem(.separator())
        pomodoroPauseItem = makePomodoroSubItem("Pause", #selector(pausePomodoro))
        menu.addItem(pomodoroPauseItem)
        pomodoroResumeItem = makePomodoroSubItem("Resume", #selector(resumePomodoro))
        menu.addItem(pomodoroResumeItem)
        pomodoroResetItem = makePomodoroSubItem("Reset", #selector(resetPomodoro))
        menu.addItem(pomodoroResetItem)
        return menu
    }

    private func makePomodoroSubItem(_ title: String, _ action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }
}
