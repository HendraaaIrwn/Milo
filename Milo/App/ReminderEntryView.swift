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

    private var canSave: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Reminder")
                .font(.title2.weight(.semibold))

            TextField("Message", text: $message)
                .textFieldStyle(.roundedBorder)

            DatePicker("Due time", selection: $dueDate)

            HStack {
                Spacer()

                Button("Cancel") {
                    onCancel()
                }

                Button("Save") {
                    onSave(message.trimmingCharacters(in: .whitespacesAndNewlines), dueDate)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}

#Preview {
    ReminderEntryView(onSave: { _, _ in }, onCancel: {})
}
