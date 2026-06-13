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

    func addReminder(message: String, dueDate: Date, source: ReminderSource = .manual) -> MiloReminder {
        let reminder = MiloReminder(message: message, dueDate: dueDate, source: source)
        reminders.append(reminder)
        sortReminders()
        save()
        return reminder
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

        reminders[index].isDone = true
        reminders[index].updatedAt = Date()
        save()
    }

    func snooze(id: UUID, minutes: Int) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }

        reminders[index].dueDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        reminders[index].updatedAt = Date()
        sortReminders()
        save()
    }

    func deleteReminder(id: UUID) {
        reminders.removeAll { $0.id == id }
        ReminderNotificationService.shared.cancelNotification(for: id)
        save()
    }

    func deleteCompleted() {
        reminders.removeAll { $0.isDone }
        save()
    }

    func dueReminders(now: Date = Date()) -> [MiloReminder] {
        reminders.filter { reminder in
            !reminder.isDone && reminder.dueDate <= now
        }
    }

    func openReminderEntryWindow(
        source: ReminderSource = .manual,
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
