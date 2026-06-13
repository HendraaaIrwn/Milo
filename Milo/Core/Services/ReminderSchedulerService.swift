//
//  ReminderSchedulerService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

@MainActor
final class ReminderSchedulerService {
    private let reminderService: ReminderService
    private let miloStateStore: MiloStateStore

    private var timerTask: Task<Void, Never>?
    private var triggeredReminderIDs: Set<UUID> = []

    init(reminderService: ReminderService, miloStateStore: MiloStateStore) {
        self.reminderService = reminderService
        self.miloStateStore = miloStateStore
    }

    func start() {
        stop()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.checkDueReminders()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        triggeredReminderIDs.removeAll()
    }

    func reschedulePendingNotifications() {
        for reminder in reminderService.pendingReminders() where reminder.dueDate > Date() {
            ReminderNotificationService.shared.scheduleNotification(for: reminder)
        }
    }

    func markDone(_ reminder: MiloReminder) {
        reminderService.markDone(id: reminder.id)
        ReminderNotificationService.shared.cancelNotification(id: reminder.localNotificationID)
        miloStateStore.hideReminder()
        triggeredReminderIDs.remove(reminder.id)
    }

    func snooze(_ reminder: MiloReminder, minutes: Int) {
        ReminderNotificationService.shared.cancelNotification(id: reminder.localNotificationID)

        if let updated = reminderService.snooze(id: reminder.id, minutes: minutes) {
            ReminderNotificationService.shared.scheduleNotification(for: updated)
        }

        miloStateStore.hideReminder()
        triggeredReminderIDs.remove(reminder.id)
    }

    func reschedule(_ reminder: MiloReminder, newDate: Date) {
        ReminderNotificationService.shared.cancelNotification(id: reminder.localNotificationID)

        if let updated = reminderService.reschedule(id: reminder.id, newDate: newDate) {
            ReminderNotificationService.shared.scheduleNotification(for: updated)
        }

        miloStateStore.hideReminder()
        triggeredReminderIDs.remove(reminder.id)
    }

    private func checkDueReminders() {
        guard !miloStateStore.shouldShowReminderBubble else { return }
        guard let reminder = reminderService.dueReminders().first else { return }
        guard !triggeredReminderIDs.contains(reminder.id) else { return }

        triggeredReminderIDs.insert(reminder.id)
        triggerReminder(reminder)
    }

    private func triggerReminder(_ reminder: MiloReminder) {
        miloStateStore.showReminder(reminder)
        ReminderSoundEngine.shared.playReminderSound(mode: reminder.soundMode)

        if reminder.soundMode == .mumble {
            MiloMumbleEngine.shared.speak("Reminder.")
        }
    }
}
