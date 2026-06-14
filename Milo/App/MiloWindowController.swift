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
    private var petPanel: FloatingPetPanel?
    private var stateCancellable: AnyCancellable?
    private var chatReminderWindow: NSWindow?
    private var historyWindow: NSWindow?
    private var rescheduleWindow: NSWindow?

    init(
        stateStore: MiloStateStore,
        reminderService: ReminderService,
        reminderHistoryService: ReminderHistoryService,
        reminderSchedulerService: ReminderSchedulerService
    ) {
        self.stateStore = stateStore
        self.reminderService = reminderService
        self.reminderHistoryService = reminderHistoryService
        self.reminderSchedulerService = reminderSchedulerService
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
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "MILO Chat Reminder"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: MiloChatInputView(
                onSubmit: { [weak self, weak window] text in
                    self?.handleChatReminder(text)
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
        petPanel?.close()
        petPanel = nil
        stateStore.isMiloVisible = false
    }

    private func handleChatReminder(_ text: String) {
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
            showBubble("Failed to add Reminder, Try another format", mood: .idle)
        }
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
}

final class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { true }
}
