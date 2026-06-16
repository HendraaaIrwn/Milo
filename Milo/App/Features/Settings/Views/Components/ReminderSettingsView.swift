//
//  ReminderSettingsView.swift
//  Milo
//

import SwiftUI

struct ReminderSettingsView: View {
    @AppStorage(MiloStorageKeys.reminderNotificationsEnabled) private var notificationsEnabled = true
    @AppStorage(MiloStorageKeys.reminderSoundEnabled) private var reminderSoundEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Notifications", subtitle: "Control reminder alerts.", systemImage: "bell.badge") {
                Toggle("Reminder Notifications Enabled", isOn: $notificationsEnabled)
                Toggle("Reminder Sound Enabled", isOn: $reminderSoundEnabled)
                Text("Reminders stay local and are saved on this Mac only.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
