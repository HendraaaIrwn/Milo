//
//  TodoRowView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct TodoRowView: View {
    let todo: MiloTodo
    let onDone: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onConvertToReminder: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: onDone) {
                Image(systemName: todo.status == .done ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .strikethrough(todo.status == .done)
                    .foregroundStyle(todo.status == .done ? .secondary : .primary)

                if let notes = todo.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    statusBadge
                    if let dueDate = todo.dueDate {
                        Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                    }
                    if todo.linkedReminderID != nil {
                        Text("🔔")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                Button("Edit", action: onEdit)
                if todo.linkedReminderID == nil {
                    Button("Convert to Reminder", action: onConvertToReminder)
                }
                Divider()
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch todo.status {
        case .active:
            Text("Active")
                .foregroundStyle(.green)
        case .done:
            Text("Done")
                .foregroundStyle(.secondary)
        case .overdue:
            Text("Overdue")
                .foregroundStyle(.red).bold()
        case .deleted:
            Text("Deleted")
                .foregroundStyle(.secondary)
        }
    }
}
