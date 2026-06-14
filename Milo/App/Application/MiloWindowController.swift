//
//  MiloWindowController.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class MiloWindowController {
    private let petState = MiloFloatingPetState()
    private let stateStore: MiloStateStore
    private let reminderService: ReminderService
    private let reminderHistoryService: ReminderHistoryService
    private let reminderSchedulerService: ReminderSchedulerService
    private let todoService: TodoService
    private let todoSchedulerService: TodoSchedulerService
    private let pomodoroService: PomodoroService
    private let codingMetricsCoordinator: CodingMetricsCoordinator
    private var petPanel: FloatingPetPanel?
    private var stateCancellable: AnyCancellable?
    private var chatReminderWindow: NSWindow?
    private var historyWindow: NSWindow?
    private var rescheduleWindow: NSWindow?
    private var todoWindow: NSWindow?
    private var todoEditorWindow: NSWindow?
    private var pomodoroSettingsWindow: NSWindow?
    private var codingMetricsWindow: NSWindow?

    init(
        stateStore: MiloStateStore,
        reminderService: ReminderService,
        reminderHistoryService: ReminderHistoryService,
        reminderSchedulerService: ReminderSchedulerService,
        todoService: TodoService,
        todoSchedulerService: TodoSchedulerService,
        pomodoroService: PomodoroService,
        codingMetricsCoordinator: CodingMetricsCoordinator
    ) {
        self.stateStore = stateStore
        self.reminderService = reminderService
        self.reminderHistoryService = reminderHistoryService
        self.reminderSchedulerService = reminderSchedulerService
        self.todoService = todoService
        self.todoSchedulerService = todoSchedulerService
        self.pomodoroService = pomodoroService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        observeStateStore(stateStore)
    }

    func showMilo() {
        if let petPanel {
            petPanel.orderFrontRegardless()
            stateStore.isMiloVisible = true
            return
        }

        let size = NSSize(width: MiloRootView.windowWidth, height: MiloRootView.windowHeight)
        let panel = FloatingPetPanel(
            contentRect: NSRect(origin: initialOrigin(for: size), size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.acceptsMouseMovedEvents = true
        panel.minSize = size
        panel.maxSize = size
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .ignoresCycle,
            .stationary
        ]

        panel.contentView = DraggableHostingView(
            rootView: MiloRootView(
                state: petState,
                stateStore: stateStore,
                pomodoroService: pomodoroService,
                codingMetricsCoordinator: codingMetricsCoordinator,
                onAddReminder: { [weak self] in
                    self?.openReminderEntry(source: .rightClick)
                },
                onChatReminder: { [weak self] in
                    self?.openChatReminder()
                },
                onOpenReminderHistory: { [weak self] in
                    self?.openReminderHistory()
                },
                onHideMilo: { [weak self] in
                    self?.hideMilo()
                },
                onReminderDone: { [weak self] reminder in
                    self?.reminderSchedulerService.markDone(reminder)
                },
                onReminderSnooze5: { [weak self] reminder in
                    self?.reminderSchedulerService.snooze(reminder, minutes: 5)
                    self?.showBubble("Reminder snoozed 5 minutes.", mood: .reminder)
                },
                onReminderSnooze15: { [weak self] reminder in
                    self?.reminderSchedulerService.snooze(reminder, minutes: 15)
                    self?.showBubble("Reminder snoozed 15 minutes.", mood: .reminder)
                },
                onReminderReschedule: { [weak self] reminder in
                    self?.openRescheduleReminder(reminder)
                },
                onTodoOpenList: { [weak self] in
                    self?.openTodoList()
                },
                onTodoOverdueDone: { [weak self] todo in
                    self?.todoSchedulerService.markDone(todo)
                },
                onAddTodo: { [weak self] in
                    self?.openTodoEditor()
                },
                onStartPomodoro: { [weak self] preset in
                    self?.startPomodoro(preset)
                },
                onPausePomodoro: { [weak self] in
                    self?.pomodoroService.pause()
                },
                onResumePomodoro: { [weak self] in
                    self?.pomodoroService.resume()
                },
                onResetPomodoro: { [weak self] in
                    self?.pomodoroService.reset()
                },
                onOpenPomodoroSettings: { [weak self] in
                    self?.openPomodoroSettings()
                },
                onOpenCodingMetrics: { [weak self] in
                    self?.openCodingMetricsPanel()
                },
                onResetCodingMetrics: { [weak self] in
                    self?.codingMetricsCoordinator.localMetricsService.resetLocalStats()
                }
            )
                .frame(width: size.width, height: size.height)
        )

        petPanel = panel
        panel.orderFrontRegardless()
        stateStore.isMiloVisible = true
    }

    func hideMilo() {
        petPanel?.orderOut(nil)
        stateStore.isMiloVisible = false
    }

    func setMood(_ mood: MiloMood) {
        petState.mood = mood
    }

    func showBubble(_ text: String, mood: MiloMood? = nil) {
        if let mood {
            petState.mood = mood
        }

        showMilo()
        petState.showBubble(text)
    }

    func openReminderEntry(source: ReminderSource) {
        reminderService.openReminderEntryWindow(source: source) { [weak self] reminder in
            ReminderNotificationService.shared.scheduleNotification(for: reminder)
            self?.showBubble("Reminder saved.", mood: .reminder)
        }
    }

    func openChatReminder() {
        if let chatReminderWindow {
            NSApp.activate(ignoringOtherApps: true)
            chatReminderWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Chat"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: MiloChatInputView(
                onSubmit: { [weak self, weak window] text in
                    self?.handleChatInput(text)
                    self?.chatReminderWindow = nil
                    window?.close()
                },
                onCancel: { [weak self, weak window] in
                    self?.chatReminderWindow = nil
                    window?.close()
                }
            )
        )

        chatReminderWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openTodoList() {
        if let todoWindow {
            NSApp.activate(ignoringOtherApps: true)
            todoWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Todo List"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: TodoListView(
                todoService: todoService,
                onEditTodo: { [weak self, weak window] todo in
                    self?.openTodoEditor(existingTodo: todo)
                    window?.close()
                },
                onConvertToReminder: { [weak self] todo in
                    self?.convertTodoToReminder(todo)
                }
            )
        )

        todoWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openTodoEditor(existingTodo: MiloTodo? = nil) {
        if let todoEditorWindow {
            NSApp.activate(ignoringOtherApps: true)
            todoEditorWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = existingTodo == nil ? "Add Todo" : "Edit Todo"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: TodoEditorView(
                todoService: todoService,
                reminderService: reminderService,
                existingTodo: existingTodo,
                source: existingTodo != nil ? existingTodo!.createdSource : .rightClick,
                onSave: { [weak self, weak window] _ in
                    self?.showBubble("Todo saved.", mood: .focus)
                    self?.todoEditorWindow = nil
                    window?.close()
                },
                onCancel: { [weak self, weak window] in
                    self?.todoEditorWindow = nil
                    window?.close()
                }
            )
        )

        todoEditorWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openReminderHistory() {
        if let historyWindow {
            NSApp.activate(ignoringOtherApps: true)
            historyWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Reminder History"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: ReminderHistoryView(historyService: reminderHistoryService)
        )

        historyWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openPomodoroSettings() {
        if let pomodoroSettingsWindow {
            NSApp.activate(ignoringOtherApps: true)
            pomodoroSettingsWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Pomodoro"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: PomodoroSettingsView(pomodoroService: pomodoroService)
        )

        pomodoroSettingsWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openCodingMetricsPanel() {
        if let codingMetricsWindow {
            NSApp.activate(ignoringOtherApps: true)
            codingMetricsWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 480),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Coding Metrics"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: CodingMetricsPanelView(
                coordinator: codingMetricsCoordinator,
                service: codingMetricsCoordinator.localMetricsService
            )
        )

        codingMetricsWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openRescheduleReminder(_ reminder: MiloReminder) {
        if let rescheduleWindow {
            NSApp.activate(ignoringOtherApps: true)
            rescheduleWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Reschedule Reminder"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: ReminderRescheduleView(
                reminder: reminder,
                onSave: { [weak self, weak window] newDate in
                    self?.reminderSchedulerService.reschedule(reminder, newDate: newDate)
                    self?.showBubble("Reminder rescheduled.", mood: .reminder)
                    self?.rescheduleWindow = nil
                    window?.close()
                },
                onCancel: { [weak self, weak window] in
                    self?.rescheduleWindow = nil
                    window?.close()
                }
            )
        )

        rescheduleWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func close() {
        stateCancellable?.cancel()
        stateCancellable = nil
        petState.clearBubble()
        chatReminderWindow?.close()
        chatReminderWindow = nil
        historyWindow?.close()
        historyWindow = nil
        rescheduleWindow?.close()
        rescheduleWindow = nil
        todoWindow?.close()
        todoWindow = nil
        todoEditorWindow?.close()
        todoEditorWindow = nil
        pomodoroSettingsWindow?.close()
        pomodoroSettingsWindow = nil
        petPanel?.close()
        petPanel = nil
        stateStore.isMiloVisible = false
    }

    private func handleChatInput(_ text: String) {
        do {
            let parsed = try TodoCommandParser.parse(text)
            let todo = todoService.addTodo(
                title: parsed.title,
                notes: parsed.notes,
                dueDate: parsed.dueDate,
                priority: parsed.priority,
                createdSource: .chat
            )

            if parsed.shouldCreateReminder, let dueDate = parsed.dueDate {
                let reminder = reminderService.addReminder(
                    title: parsed.title,
                    message: parsed.title,
                    dueDate: dueDate,
                    createdSource: .todo
                )

                todoService.attachReminder(todoID: todo.id, reminderID: reminder.id)
                ReminderNotificationService.shared.scheduleNotification(for: reminder)

                showBubble("Todo added with reminder.", mood: .reminder)
            } else {
                showBubble("Todo added.", mood: .focus)
            }

            return
        } catch TodoCommandParserError.unsupportedFormat {
            // Unsupported todo format; fall through to try parsing as a reminder
        } catch {
            // Other parsing errors; fall through to reminder parsing
        }

        do {
            let parsed = try NaturalLanguageReminderParser.parse(text)
            let reminder = reminderService.addReminder(
                title: parsed.title,
                message: parsed.message,
                dueDate: parsed.dueDate,
                createdSource: .chat
            )

            ReminderNotificationService.shared.scheduleNotification(for: reminder)
            showBubble("Reminder set: \(parsed.message)", mood: .reminder)
        } catch {
            showBubble("Try: buat todo update README besok jam 10", mood: .idle)
        }
    }

    private func convertTodoToReminder(_ todo: MiloTodo) {
        guard let dueDate = todo.dueDate else {
            openTodoEditor(existingTodo: todo)
            return
        }

        let reminder = reminderService.addReminder(
            title: todo.title,
            message: todo.title,
            dueDate: dueDate,
            createdSource: .todo
        )

        todoService.attachReminder(todoID: todo.id, reminderID: reminder.id)
        ReminderNotificationService.shared.scheduleNotification(for: reminder)

        showBubble("Todo converted to reminder.", mood: .reminder)
    }

    func startPomodoro(_ preset: PomodoroPreset) {
        pomodoroService.start(preset: preset)
        showBubble("Pomodoro started. Let’s focus.", mood: .focus)
    }

    private func observeStateStore(_ stateStore: MiloStateStore) {
        stateCancellable = stateStore.$animationState
            .sink { [weak self] animationState in
                Task { @MainActor [weak self] in
                    self?.petState.mood = animationState.miloMood
                }
            }
    }

    private func initialOrigin(for size: NSSize) -> NSPoint {
        guard let visibleFrame = NSScreen.main?.visibleFrame else { return .zero }

        return NSPoint(
            x: visibleFrame.midX - size.width * 0.5,
            y: visibleFrame.midY - size.height * 0.5
        )
    }
}

final class FloatingPetPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}

final class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { true }
}

