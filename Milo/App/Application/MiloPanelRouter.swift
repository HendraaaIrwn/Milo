//
//  MiloPanelRouter.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class MiloPanelRouter {
    private let deps: MiloPanelDependencies

    var onOpenSettings: (() -> Void)?
    var onHideMilo: (() -> Void)?

    private var chatCommandWindow: UtilityWindowController?
    private var addReminderWindow: UtilityWindowController?
    private var addTodoWindow: UtilityWindowController?
    private var pomodoroSettingsWindow: UtilityWindowController?
    private var todoListWindow: UtilityWindowController?
    private var reminderHistoryWindow: UtilityWindowController?
    private var codingMetricsWindow: UtilityWindowController?
    private var weeklySummaryWindow: UtilityWindowController?

    init(dependencies: MiloPanelDependencies) {
        self.deps = dependencies
    }

    func openChatCommand() {
        if let w = chatCommandWindow { w.show(); return }
        let ctrl = UtilityWindowController(
            title: "Chat Reminder & Todo",
            sizing: .chatReminderTodo,
            rootView: ChatCommandWindowView(
                reminderService: deps.reminderService,
                todoService: deps.todoService,
                reminderSchedulerService: deps.reminderSchedulerService,
                todoSchedulerService: deps.todoSchedulerService,
                onShowBubble: deps.showBubble,
                onClose: { [weak self] in self?.chatCommandWindow?.close() }
            )
        )
        ctrl.onClose = { [weak self] in self?.chatCommandWindow = nil }
        chatCommandWindow = ctrl
        ctrl.show()
    }

    func openAddReminder() {
        if let w = addReminderWindow { w.show(); return }
        addReminderWindow = reminderEntryWindow()
        addReminderWindow?.show()
    }

    func openAddTodo() {
        if let w = addTodoWindow { w.show(); return }
        addTodoWindow = todoEditorWindow(todo: nil)
        addTodoWindow?.show()
    }

    func openPomodoroSettings() {
        if let w = pomodoroSettingsWindow { w.show(); return }
        let ctrl = UtilityWindowController(
            title: "MILO Pomodoro",
            sizing: .pomodoroSettings,
            rootView: PomodoroSettingsView(pomodoroService: deps.pomodoroService)
        )
        ctrl.onClose = { [weak self] in self?.pomodoroSettingsWindow = nil }
        pomodoroSettingsWindow = ctrl
        ctrl.show()
    }

    func openTodoList() {
        if let w = todoListWindow { w.show(); return }
        let ctrl = UtilityWindowController(
            title: "Todo List",
            sizing: .todoList,
            rootView: TodoListView(
                todoService: deps.todoService,
                onAddTodo: { [weak self] in self?.openAddTodo() },
                onEditTodo: { [weak self] todo in self?.openEditTodo(todo) },
                onConvertToReminder: { [weak self] todo in self?.convertTodoToReminder(todo) }
            )
        )
        ctrl.onClose = { [weak self] in self?.todoListWindow = nil }
        todoListWindow = ctrl
        ctrl.show()
    }

    func openReminderHistory() {
        if let w = reminderHistoryWindow { w.show(); return }
        let ctrl = UtilityWindowController(
            title: "Reminder History",
            sizing: .reminderHistory,
            rootView: ReminderHistoryView(historyService: deps.reminderHistoryService)
        )
        ctrl.onClose = { [weak self] in self?.reminderHistoryWindow = nil }
        reminderHistoryWindow = ctrl
        ctrl.show()
    }

    func openCodingMetrics() {
        if let w = codingMetricsWindow { w.show(); return }
        let ctrl = UtilityWindowController(
            title: "Coding Metrics",
            sizing: .codingMetrics,
            rootView: CodingMetricsPanelView(
                coordinator: deps.codingMetricsCoordinator,
                service: deps.codingMetricsCoordinator.localMetricsService,
                onOpenWeeklySummary: { [weak self] in self?.openWeeklyCodingSummary() },
                onOpenFileWatcherSettings: {}
            )
        )
        ctrl.onClose = { [weak self] in self?.codingMetricsWindow = nil }
        codingMetricsWindow = ctrl
        ctrl.show()
    }

    func openWeeklyCodingSummary() {
        if let w = weeklySummaryWindow { w.show(); return }
        let ctrl = UtilityWindowController(
            title: "Weekly Coding Summary",
            sizing: .weeklyCodingSummary,
            rootView: WeeklyCodingSummaryView(
                weeklyService: deps.codingMetricsCoordinator.weeklyMetricsService
            )
        )
        ctrl.onClose = { [weak self] in self?.weeklySummaryWindow = nil }
        weeklySummaryWindow = ctrl
        ctrl.show()
    }

    func openSettings() {
        onOpenSettings?()
    }

    func hideMilo() {
        onHideMilo?()
    }

    // MARK: - Private helpers

    private func reminderEntryWindow() -> UtilityWindowController {
        let ctrl = UtilityWindowController(
            title: "Add Reminder",
            sizing: .addReminder,
            rootView: ReminderEntryView(
                onSave: { [weak self] title, date in
                    let reminder = self?.deps.reminderService.addReminder(
                        title: title, message: title, dueDate: date, createdSource: .rightClick
                    )
                    if let reminder {
                        ReminderNotificationService.shared.scheduleNotification(for: reminder)
                    }
                    self?.deps.showBubble("Reminder saved.")
                    self?.addReminderWindow?.close()
                },
                onCancel: { [weak self] in self?.addReminderWindow?.close() }
            )
        )
        ctrl.onClose = { [weak self] in self?.addReminderWindow = nil }
        return ctrl
    }

    private func todoEditorWindow(todo: MiloTodo?) -> UtilityWindowController {
        let title = todo != nil ? "Edit Todo" : "Add Todo"
        let ctrl = UtilityWindowController(
            title: title,
            sizing: .addTodo,
            rootView: TodoEditorView(
                todoService: deps.todoService,
                reminderService: deps.reminderService,
                existingTodo: todo,
                source: todo?.createdSource ?? .rightClick,
                onSave: { [weak self] _ in
                    self?.deps.showBubble(todo != nil ? "Todo updated." : "Todo added.")
                    self?.addTodoWindow?.close()
                },
                onCancel: { [weak self] in self?.addTodoWindow?.close() }
            )
        )
        ctrl.onClose = { [weak self] in self?.addTodoWindow = nil }
        return ctrl
    }

    private func openEditTodo(_ todo: MiloTodo) {
        addTodoWindow?.close()
        addTodoWindow = nil
        addTodoWindow = todoEditorWindow(todo: todo)
        addTodoWindow?.show()
    }

    private func convertTodoToReminder(_ todo: MiloTodo) {
        guard let dueDate = todo.dueDate else { return }
        let reminder = deps.reminderService.addReminder(
            title: todo.title, message: todo.title, dueDate: dueDate, createdSource: .todo
        )
        deps.todoService.attachReminder(todoID: todo.id, reminderID: reminder.id)
        ReminderNotificationService.shared.scheduleNotification(for: reminder)
        deps.showBubble("Todo converted to reminder.")
    }

    func cleanup() {
        chatCommandWindow?.close()
        addReminderWindow?.close()
        addTodoWindow?.close()
        pomodoroSettingsWindow?.close()
        todoListWindow?.close()
        reminderHistoryWindow?.close()
        codingMetricsWindow?.close()
        weeklySummaryWindow?.close()
    }
}
