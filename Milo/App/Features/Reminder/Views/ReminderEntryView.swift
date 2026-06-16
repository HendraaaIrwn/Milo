//
//  ReminderEntryView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct ReminderEntryView: View {
    let onSave: @MainActor (String, Date) -> Void
    let onCancel: @MainActor () -> Void

    @State private var message = ""
    @State private var dueDate = Date().addingTimeInterval(30 * 60)
    @State private var showEmptyWarning = false

    private var cleanMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !cleanMessage.isEmpty
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Add Reminder",
            subtitle: "Create a reminder bubble, sound, and notification.",
            systemImage: "bell.badge.fill"
        ) {
            MiloPanelCardView(
                title: "Reminder Form",
                subtitle: "Use a short message and a clear due time."
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Message", text: $message)
                        .textFieldStyle(.roundedBorder)

                    DatePicker(
                        "Due time",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    Spacer()

                    HStack {
                        Spacer()
                        Button("Cancel") { onCancel() }
                        Button {
                            guard canSave else {
                                showEmptyWarning = true
                                return
                            }
                            onSave(cleanMessage, dueDate)
                        } label: {
                            Label("Save Reminder", systemImage: "bell.badge.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }

            if showEmptyWarning {
                MiloPanelCardView(
                    title: "Message Required",
                    subtitle: "Please enter a reminder message before saving."
                ) {
                    Button("OK") { showEmptyWarning = false }
                }
            }

//            MiloPanelCardView(
//                title: "Preview",
//                subtitle: "MILO shows this as a reminder bubble when it is due."
//            ) {
//                VStack(alignment: .leading, spacing: 10) {
//                    Text(cleanMessage.isEmpty ? "Reminder message preview" : cleanMessage)
//                        .font(.system(size: 14, weight: .black, design: .rounded))
//                        .foregroundStyle(cleanMessage.isEmpty ? .secondary : .primary)
//                        .lineLimit(2)
//
//                    HStack(spacing: 8) {
//                        MiloStatusPillView(title: dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar.badge.clock", tone: .info)
//                        MiloStatusPillView(title: "Local", systemImage: "lock.fill", tone: .success)
//                    }
//                }
//            }
        } footer: {
            MiloPanelFooterView(
                message: "Reminder data is stored locally.",
                statusTitle: canSave ? "Ready" : "Message Required",
                statusTone: canSave ? .success : .warning
            )
        }
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    ReminderEntryView(onSave: { _, _ in }, onCancel: {})
}
#endif
