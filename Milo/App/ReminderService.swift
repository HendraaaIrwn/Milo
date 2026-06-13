//
//  ReminderService.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class ReminderService: ObservableObject {
    @Published private(set) var reminders: [MiloReminder] = []

    private let storage: MiloLocalStorageService
    private var entryWindow: NSWindow?

    convenience init() {
        self.init(storage: .shared)
    }

    init(storage: MiloLocalStorageService) {
        self.storage = storage
        load()
    }

    func load() {
        reminders = storage.load(
            [MiloReminder].self,
            forKey: MiloStorageKeys.reminders,
            defaultValue: []
        )
        sortReminders()
    }

    func save() {
        storage.save(reminders, forKey: MiloStorageKeys.reminders)
    }

    @discardableResult
    func addReminder(
        title: String,
        message: String,
        dueDate: Date,
        repeatRule: ReminderRepeatRule? = nil,
        soundMode: ReminderSoundMode = .mumble,
        createdSource: ReminderCreatedSource
    ) -> MiloReminder {
        let reminder = MiloReminder(
            title: title,
            message: message,
            dueDate: dueDate,
            repeatRule: repeatRule,
            soundMode: soundMode,
            createdSource: createdSource
        )

        reminders.append(reminder)
        sortReminders()
        save()
        return reminder
    }

    @discardableResult
    func addReminder(message: String, dueDate: Date, source: ReminderSource = .rightClick) -> MiloReminder {
        addReminder(
            title: message,
            message: message,
            dueDate: dueDate,
            createdSource: source
        )
    }

    func updateReminder(_ reminder: MiloReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }

        var updated = reminder
        updated.updatedAt = Date()
        reminders[index] = updated
        sortReminders()
        save()
    }

    func markDone(id: UUID) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }

        reminders[index].isCompleted = true
        reminders[index].updatedAt = Date()
        save()
    }

    func snooze(id: UUID, minutes: Int) -> MiloReminder? {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return nil }

        reminders[index].dueDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        reminders[index].isCompleted = false
        reminders[index].updatedAt = Date()
        reminders[index].localNotificationID = UUID().uuidString
        sortReminders()
        save()
        return reminders.first { $0.id == id }
    }

    func reschedule(id: UUID, newDate: Date) -> MiloReminder? {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return nil }

        reminders[index].dueDate = newDate
        reminders[index].isCompleted = false
        reminders[index].updatedAt = Date()
        reminders[index].localNotificationID = UUID().uuidString
        sortReminders()
        save()
        return reminders.first { $0.id == id }
    }

    func deleteReminder(id: UUID) {
        if let reminder = reminders.first(where: { $0.id == id }) {
            ReminderNotificationService.shared.cancelNotification(id: reminder.localNotificationID)
        }

        reminders.removeAll { $0.id == id }
        save()
    }

    func deleteCompleted() {
        let completed = reminders.filter(\.isCompleted)
        completed.forEach { ReminderNotificationService.shared.cancelNotification(id: $0.localNotificationID) }
        reminders.removeAll { $0.isCompleted }
        save()
    }

    func dueReminders(now: Date = Date()) -> [MiloReminder] {
        reminders.filter { reminder in
            !reminder.isCompleted && reminder.dueDate <= now
        }
    }

    func pendingReminders() -> [MiloReminder] {
        reminders.filter { !$0.isCompleted }
    }

    func openReminderEntryWindow(
        source: ReminderSource = .rightClick,
        onSave: @MainActor @escaping (MiloReminder) -> Void
    ) {
        if let entryWindow {
            NSApp.activate(ignoringOtherApps: true)
            entryWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 210),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Add Reminder"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = NSHostingController(
            rootView: ReminderEntryView(
                onSave: { [weak self, weak window] message, dueDate in
                    guard let self else { return }

                    let reminder = addReminder(message: message, dueDate: dueDate, source: source)
                    closeEntryWindow()
                    onSave(reminder)
                    window?.close()
                },
                onCancel: { [weak self] in
                    self?.closeEntryWindow()
                }
            )
        )

        entryWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func closeEntryWindow() {
        entryWindow?.close()
        entryWindow = nil
    }

    private func sortReminders() {
        reminders.sort { lhs, rhs in
            lhs.dueDate < rhs.dueDate
        }
    }
}
