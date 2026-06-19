//
//  ReminderRescheduleView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct ReminderRescheduleView: View {
    private var metrics = MiloScaledMetrics()

    let reminder: MiloReminder
    let onSave: @MainActor (Date) -> Void
    let onCancel: @MainActor () -> Void

    @State private var dueDate: Date
    @State private var showPastWarning = false

    private var canSave: Bool {
        dueDate > Date()
    }

    init(
        reminder: MiloReminder,
        onSave: @MainActor @escaping (Date) -> Void,
        onCancel: @MainActor @escaping () -> Void
    ) {
        self.reminder = reminder
        self.onSave = onSave
        self.onCancel = onCancel
        _dueDate = State(initialValue: max(reminder.dueDate, Date().addingTimeInterval(5 * 60)))
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Reschedule Reminder",
            subtitle: "Pick a new time for this reminder.",
            systemImage: "calendar.badge.clock"
        ) {
            MiloPanelCardView(
                title: "Reminder",
                subtitle: "MILO will show this again at the new time."
            ) {
                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    Text(reminder.message)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    MiloStatusPillView(
                        title: "Current: \(reminder.dueDate.formatted(date: .abbreviated, time: .shortened))",
                        systemImage: "clock",
                        tone: .neutral
                    )
                }
            }

            MiloPanelCardView(
                title: "New Time",
                subtitle: "Choose a future date and time."
            ) {
                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    DatePicker(
                        "Due time",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)

                    MiloStatusPillView(
                        title: "New: \(dueDate.formatted(date: .abbreviated, time: .shortened))",
                        systemImage: "calendar",
                        tone: canSave ? .success : .warning
                    )

                    if showPastWarning {
                        Text("Choose a future time before saving.")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                        Button {
                            guard canSave else {
                                showPastWarning = true
                                return
                            }
                            onSave(dueDate)
                        } label: {
                            Label("Save New Time", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }
        } footer: {
            MiloPanelFooterView(
                message: "Reminder data stays local on this Mac.",
                statusTitle: canSave ? "Ready" : "Future Time Required",
                statusTone: canSave ? .success : .warning
            )
        }
    }
}

#if DEBUG
#Preview {
    ReminderRescheduleView(
        reminder: MiloReminder(
            title: "Stretch",
            message: "Stretch and drink water.",
            dueDate: Date().addingTimeInterval(60),
            createdSource: .rightClick
        ),
        onSave: { _ in },
        onCancel: {}
    )
}
#endif
