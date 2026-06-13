//
//  ReminderNotificationService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation
import UserNotifications

final class ReminderNotificationService {
    static let shared = ReminderNotificationService()

    private init() {}

    func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                print("Notification permission error: \(error.localizedDescription)")
            }

            print("Notification permission granted: \(granted)")
        }
    }

    func scheduleNotification(for reminder: MiloReminder) {
        guard isReminderNotificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "MILO Reminder"
        content.subtitle = "⏰ Time to check this"
        content.body = reminder.message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, reminder.dueDate.timeIntervalSinceNow),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule reminder notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotification(for reminderID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminderID.uuidString]
        )
    }

    private var isReminderNotificationsEnabled: Bool {
        guard UserDefaults.standard.object(forKey: MiloStorageKeys.reminderNotificationsEnabled) != nil else {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.reminderNotificationsEnabled)
    }
}
