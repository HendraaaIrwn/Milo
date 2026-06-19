//
//  ReminderEntryView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct ReminderEntryView: View {
    private var metrics = MiloScaledMetrics()
    
    let onSave: @MainActor (String, Date) -> Void
    let onCancel: @MainActor () -> Void
    
    init(
        onSave: @escaping @MainActor (String, Date) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
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
                VStack(alignment: .leading, spacing: metrics.cardPadding) {
                    TextField("Message", text: $message)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker(
                        "Due time",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
        
                    MiloAdaptiveActionRow {
                        Button {
                            guard canSave else {
                                showEmptyWarning = true
                                return
                            }
                            onSave(cleanMessage, dueDate)
                        } label: {
                            Label("Save Reminder", systemImage: "bell.badge.fill")
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                        .keyboardShortcut(.defaultAction)
                        Button("Cancel") { onCancel() }
                            .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    }
                    .padding(.top, metrics.largeSpacing)
                }
            }
            
            if showEmptyWarning {
                MiloPanelCardView(
                    title: "Message Required",
                    subtitle: "Please enter a reminder message before saving."
                ) {
                    Button("OK") { showEmptyWarning = false }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
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

#if DEBUG
#Preview {
    ReminderEntryView(onSave: { _, _ in }, onCancel: {})
}
#endif
