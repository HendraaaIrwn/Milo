//
//  ReminderRescheduleView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct ReminderRescheduleView: View {
    let reminder: MiloReminder
    let onSave: @MainActor (Date) -> Void
    let onCancel: @MainActor () -> Void

    @State private var dueDate: Date

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
        VStack(alignment: .leading, spacing: 16) {
            Text("Reschedule Reminder")
                .font(.title2.weight(.semibold))

            Text(reminder.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            DatePicker("New time", selection: $dueDate)

            HStack {
                Spacer()

                Button("Cancel") {
                    onCancel()
                }

                Button("Save") {
                    onSave(dueDate)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 380)
    }
}
