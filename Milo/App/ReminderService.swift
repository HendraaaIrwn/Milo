//
//  ReminderService.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import AppKit
import Combine
import SwiftUI

struct MiloReminder: Codable, Identifiable, Equatable {
    let id: UUID
    let message: String
    let dueDate: Date

    init(id: UUID = UUID(), message: String, dueDate: Date) {
        self.id = id
        self.message = message
        self.dueDate = dueDate
    }
}

@MainActor
final class ReminderService: ObservableObject {
    @Published private(set) var reminders: [MiloReminder] = []

    private let storageKey = "miloReminders"
    private var entryWindow: NSWindow?

    init() {
        loadReminders()
    }

    func openReminderEntryWindow(onSave: @MainActor @escaping (MiloReminder) -> Void) {
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

                    let reminder = MiloReminder(message: message, dueDate: dueDate)
                    reminders.append(reminder)
                    saveReminders()
                    closeEntryWindow()
                    onSave(reminder)
                    print("Reminder saved: \(message)")
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

    private func loadReminders() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let savedReminders = try? JSONDecoder().decode([MiloReminder].self, from: data)
        else { return }

        reminders = savedReminders
    }

    private func saveReminders() {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
