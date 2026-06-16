//
//  TodoSettingsView.swift
//  Milo
//

import SwiftUI

struct TodoSettingsView: View {
    @AppStorage(MiloStorageKeys.reminderNotificationsEnabled) private var todoNotificationsEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Todo List", subtitle: "Manage todo behavior.", systemImage: "checklist") {
                Toggle("Show overdue todo bubbles", isOn: $todoNotificationsEnabled)
                Text("Todos are stored locally and persist after restart.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
