//
//  ReminderNotificationService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import AppKit
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
        guard notificationsEnabled else { return }
        guard reminder.dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "MILO Reminder"
        content.subtitle = "⏰ Reminder due"
        content.body = reminder.message
        content.sound = .default
        content.attachments = miloIconAttachment().map { [$0] } ?? []

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, reminder.dueDate.timeIntervalSinceNow),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminder.localNotificationID,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule reminder notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelNotification(for reminderID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderID.uuidString])
    }

    private var notificationsEnabled: Bool {
        guard UserDefaults.standard.object(forKey: MiloStorageKeys.reminderNotificationsEnabled) != nil else {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.reminderNotificationsEnabled)
    }

    private func miloIconAttachment() -> UNNotificationAttachment? {
        guard let url = miloIconFileURL() else { return nil }

        do {
            return try UNNotificationAttachment(identifier: "milo-icon", url: url)
        } catch {
            print("Failed to attach Milo icon to reminder notification: \(error.localizedDescription)")
            return nil
        }
    }

    private func miloIconFileURL() -> URL? {
        let fileManager = FileManager.default
        let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let iconURL = cacheURL?.appendingPathComponent("milo-reminder-icon.png") else { return nil }

        if fileManager.fileExists(atPath: iconURL.path) {
            return iconURL
        }

        guard
            let image = NSImage(named: "Body"),
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let pngData = bitmap.representation(using: .png, properties: [:])
        else {
            return nil
        }

        do {
            try pngData.write(to: iconURL, options: .atomic)
            return iconURL
        } catch {
            print("Failed to cache Milo reminder icon: \(error.localizedDescription)")
            return nil
        }
    }
}
