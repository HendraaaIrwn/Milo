//
//  MiloWindowController.swift
//  Milo
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class MiloWindowController {
    private let petState = MiloFloatingPetState()
    private let stateStore: MiloStateStore
    private let mousePositionService = MousePositionService()
    private let reminderService: ReminderService
    private let reminderHistoryService: ReminderHistoryService
    private let reminderSchedulerService: ReminderSchedulerService
    private let todoService: TodoService
    private let todoSchedulerService: TodoSchedulerService
    private let pomodoroService: PomodoroService
    private let codingMetricsCoordinator: CodingMetricsCoordinator
    private let fileWatcherService: ProjectFileWatcherService
    private var petPanel: FloatingPetPanel?

    private var stateCancellable: AnyCancellable?
    private var pomodoroCancellable: AnyCancellable?
    private var reactionCancellable: AnyCancellable?
    private var reminderBubbleCancellable: AnyCancellable?
    private var todoBubbleCancellable: AnyCancellable?
    private var typingBubbleCancellable: AnyCancellable?
    private var codingBadgeCancellable: AnyCancellable?
    private var pomodoroBadgeCancellable: AnyCancellable?
    private var frameObserver: NSObjectProtocol?

    private var chatReminderWindow: NSWindow?
    private var historyWindow: NSWindow?
    private var rescheduleWindow: NSWindow?
    private var todoWindow: NSWindow?
    private var todoEditorWindow: NSWindow?
    private var codingMetricsWindow: NSWindow?
    private var weeklyCodingSummaryWindow: NSWindow?

    private lazy var codingBadgeController = CodingMetricsBadgeWindowController(
        service: codingMetricsCoordinator.localMetricsService
    )
    private lazy var bubbleController = MiloBubbleWindowController()
    private lazy var pomodoroBadgeController = MiloPomodoroBadgeWindowController(
        pomodoroService: pomodoroService
    )
    private lazy var todoBubbleController = MiloTodoBubbleWindowController()
    private lazy var reminderBubbleController = MiloReminderBubbleWindowController()

    private lazy var overlayCoordinator = MiloOverlayCoordinator(
        codingBadgeController: codingBadgeController,
        bubbleController: bubbleController,
        pomodoroBadgeController: pomodoroBadgeController,
        todoBubbleController: todoBubbleController,
        reminderBubbleController: reminderBubbleController
    )

    private lazy var fileWatcherSettingsWindowController = FileWatcherSettingsWindowController(
        fileWatcherService: fileWatcherService
    )
    private lazy var settingsWindowController = SettingsWindowController(
        dependencies: SettingsDependencies(
            reminderService: reminderService,
            todoService: todoService,
            pomodoroService: pomodoroService,
            codingMetricsCoordinator: codingMetricsCoordinator,
            fileWatcherService: fileWatcherService
        )
    )
    private(set) lazy var panelRouter = MiloPanelRouter(
        dependencies: MiloPanelDependencies(
            miloStateStore: stateStore,
            reminderService: reminderService,
            reminderHistoryService: reminderHistoryService,
            reminderSchedulerService: reminderSchedulerService,
            todoService: todoService,
            todoSchedulerService: todoSchedulerService,
            pomodoroService: pomodoroService,
            codingMetricsCoordinator: codingMetricsCoordinator,
            showBubble: { [weak self] text in self?.showBubble(text) }
        )
    )
    private lazy var contextMenuController = MiloContextMenuController(
        panelRouter: panelRouter,
        miloStateStore: stateStore,
        pomodoroService: pomodoroService
    )

    init(
        stateStore: MiloStateStore,
        reminderService: ReminderService,
        reminderHistoryService: ReminderHistoryService,
        reminderSchedulerService: ReminderSchedulerService,
        todoService: TodoService,
        todoSchedulerService: TodoSchedulerService,
        pomodoroService: PomodoroService,
        codingMetricsCoordinator: CodingMetricsCoordinator,
        fileWatcherService: ProjectFileWatcherService
    ) {
        self.stateStore = stateStore
        self.reminderService = reminderService
        self.reminderHistoryService = reminderHistoryService
        self.reminderSchedulerService = reminderSchedulerService
        self.todoService = todoService
        self.todoSchedulerService = todoSchedulerService
        self.pomodoroService = pomodoroService
        self.codingMetricsCoordinator = codingMetricsCoordinator
        self.fileWatcherService = fileWatcherService
        observeStateStore(stateStore)
        observeOverlayTriggers()
        observeFrameChanges()
    }

    func showMilo() {
        panelRouter.onOpenSettings = { [weak self] in self?.openSettings() }
        panelRouter.onHideMilo = { [weak self] in self?.hideMilo() }

        if petPanel == nil {
            createCharacterWindow()
            overlayCoordinator.configureAll()
        }

        mousePositionService.start()
        petPanel?.orderFrontRegardless()
        stateStore.isMiloVisible = true

        if let frame = petPanel?.frame {
            overlayCoordinator.updatePositions(relativeTo: frame)
        }

        updateCodingBadgeVisibility()
        updatePomodoroBadgeVisibility()
    }

    func hideMilo() {
        petPanel?.orderOut(nil)
        stateStore.isMiloVisible = false
        overlayCoordinator.hideAllEventOverlays()
        overlayCoordinator.hideCodingBadge()
        overlayCoordinator.hidePomodoroBadge()
    }

    func setMood(_ mood: MiloMood) {
        petState.mood = mood
    }

    func showBubble(_ text: String, mood: MiloMood? = nil, source: MiloBubbleSource = .system) {
        if let mood { petState.mood = mood }
        showMilo()
        petState.showBubble(text)
    }

    private func createCharacterWindow() {
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
        panel.ignoresMouseEvents = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = false
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

        petPanel = panel

        panel.contentView = DraggableHostingView(
            rootView: MiloRootView(
                mousePositionService: mousePositionService,
                state: petState,
                stateStore: stateStore,
                contextMenuController: contextMenuController,
                onLeftClick: { [weak self] in
                    let text = MiloReactionLineProvider.randomLine(excluding: self?.petState.reactionText)
                    self?.showBubble(text)
                },
                characterFrame: { [weak panel] in
                    panel?.frame ?? .zero
                }
            )
            .frame(width: size.width, height: size.height)
        )

        panel.orderFrontRegardless()
        stateStore.isMiloVisible = true
    }

    private func observeFrameChanges() {
        frameObserver = NotificationCenter.default.addObserver(
            forName: .miloCharacterWindowDidMove,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let frameValue = (notification.userInfo)?["frame"] as? NSValue else { return }
            let frame = frameValue.rectValue
            Task { @MainActor [weak self] in
                self?.overlayCoordinator.updatePositions(relativeTo: frame)
            }
        }
    }

    private func observeOverlayTriggers() {
        reactionCancellable = petState.$reactionText
            .dropFirst()
            .sink { [weak self] text in
                guard let self, let text, let frame = self.petPanel?.frame else { return }
                self.overlayCoordinator.updatePositions(relativeTo: frame)
                self.overlayCoordinator.showBubble(
                    text: text,
                    source: .click,
                    priority: .normal,
                    duration: 3
                )
            }

        reminderBubbleCancellable = stateStore.$shouldShowReminderBubble
            .sink { [weak self] shouldShow in
                guard let self else { return }
                if shouldShow, let reminder = self.stateStore.activeReminder,
                   let frame = self.petPanel?.frame {
                    self.overlayCoordinator.updatePositions(relativeTo: frame)
                    self.overlayCoordinator.showReminderBubble(
                        reminder: reminder,
                        duration: 5,
                        onDone: { [weak self] in
                            self?.reminderSchedulerService.markDone(reminder)
                        },
                        onSnooze5: { [weak self] in
                            self?.reminderSchedulerService.snooze(reminder, minutes: 5)
                            self?.showBubble("Reminder snoozed 5 minutes.", mood: .reminder, source: .system)
                        },
                        onSnooze15: { [weak self] in
                            self?.reminderSchedulerService.snooze(reminder, minutes: 15)
                            self?.showBubble("Reminder snoozed 15 minutes.", mood: .reminder, source: .system)
                        },
                        onReschedule: { [weak self] in
                            self?.openRescheduleReminder(reminder)
                        }
                    )
                } else {
                    self.overlayCoordinator.hideReminderBubble()
                }
            }

        todoBubbleCancellable = stateStore.$shouldShowTodoBubble
            .sink { [weak self] shouldShow in
                guard let self else { return }
                if shouldShow, let todo = self.stateStore.activeTodoBubble,
                   let frame = self.petPanel?.frame {
                    self.overlayCoordinator.updatePositions(relativeTo: frame)
                    self.overlayCoordinator.showTodoBubble(
                        todo: todo,
                        duration: 5,
                        onDone: { [weak self] in
                            self?.todoSchedulerService.markDone(todo)
                        },
                        onOpenTodoList: { [weak self] in
                            self?.panelRouter.openTodoList()
                        }
                    )
                } else {
                    self.overlayCoordinator.hideTodoBubble()
                }
            }

        typingBubbleCancellable = stateStore.$shouldShowTypingBubble
            .sink { [weak self] shouldShow in
                guard let self else { return }
                if shouldShow, let text = self.stateStore.typingBubbleText,
                   let frame = self.petPanel?.frame {
                    self.overlayCoordinator.updatePositions(relativeTo: frame)
                    self.overlayCoordinator.showBubble(
                        text: text,
                        source: .typing,
                        priority: .low,
                        duration: 2.5
                    )
                }
            }

        pomodoroCancellable = pomodoroService.$session
            .map { $0.runState }
            .removeDuplicates()
            .sink { [weak self] runState in
                Task { @MainActor [weak self] in
                    self?.updatePomodoroBadgeVisibility()
                }
            }

        pomodoroBadgeCancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.updatePomodoroBadgeVisibility()
                    self?.updateCodingBadgeVisibility()
                }
            }
    }

    private func updateCodingBadgeVisibility() {
        let showBadge = UserDefaults.standard.object(forKey: MiloStorageKeys.codingMetricsShowBadge) as? Bool ?? true
        guard let frame = petPanel?.frame else { return }

        if showBadge {
            overlayCoordinator.updatePositions(relativeTo: frame)
            overlayCoordinator.showCodingBadge()
        } else {
            overlayCoordinator.hideCodingBadge()
        }
    }

    private func updatePomodoroBadgeVisibility() {
        let showBadge = UserDefaults.standard.object(forKey: MiloStorageKeys.pomodoroShowTimerBadge) as? Bool ?? true
        let isRunning = pomodoroService.session.runState == .running ||
                         pomodoroService.session.runState == .paused
        let shouldShow = showBadge && isRunning

        guard let frame = petPanel?.frame else { return }

        overlayCoordinator.updatePositions(relativeTo: frame)
        overlayCoordinator.updatePomodoroBadge(isRunning: shouldShow)
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

        window.title = "Reschedule"
        window.isReleasedWhenClosed = false
        window.center()
        // Placeholder for reschedule UI

        rescheduleWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openCodingMetrics() {
        if let codingMetricsWindow {
            NSApp.activate(ignoringOtherApps: true)
            codingMetricsWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Coding Metrics"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: CodingMetricsPanelView(
                coordinator: codingMetricsCoordinator,
                service: codingMetricsCoordinator.localMetricsService,
                onOpenWeeklySummary: { [weak self] in
                    self?.openWeeklyCodingSummary()
                },
                onOpenFileWatcherSettings: { [weak self] in
                    self?.openFileWatcherSettings()
                }
            )
        )

        codingMetricsWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openWeeklyCodingSummary() {
        if let weeklyCodingSummaryWindow {
            NSApp.activate(ignoringOtherApps: true)
            weeklyCodingSummaryWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 620),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Weekly Coding Summary"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: WeeklyCodingSummaryView(
                weeklyService: codingMetricsCoordinator.weeklyMetricsService
            )
        )

        weeklyCodingSummaryWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func openFileWatcherSettings() {
        fileWatcherSettingsWindowController.show()
    }

    func openSettings() {
        settingsWindowController.show()
    }

    func startPomodoro(_ preset: PomodoroPreset) {
        pomodoroService.start(preset: preset)
        showBubble("Pomodoro started. Let's focus.", mood: .focus)
    }

    func destroy() {
        mousePositionService.stop()
        overlayCoordinator.destroyAll()
        frameObserver.map { NotificationCenter.default.removeObserver($0) }
        frameObserver = nil
        petPanel?.orderOut(nil)
        petPanel?.close()
        petPanel = nil
    }

    func close() {
        destroy()
    }
}

// MARK: - Private Helpers

extension MiloWindowController {
    private func handleChatInput(_ text: String) {
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

// MARK: - Window Subclasses

final class FloatingPetPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}

final class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let result = super.hitTest(point) else {
            return nil
        }

        if result is MiloRightClickHitView {
            return result
        }

        if result is NSControl {
            return result
        }

        let className = String(describing: type(of: result))
        if className.contains("MiloRightClickHitView") {
            return result
        }

        if result.self === self {
            return nil
        }

        return nil
    }
}
