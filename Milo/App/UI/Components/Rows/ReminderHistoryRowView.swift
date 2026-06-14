//
//  ReminderHistoryRowView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct ReminderHistoryRowView: View {
    let event: MiloReminderHistoryEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.title)
                        .font(.headline)
                        .lineLimit(1)

                    if event.message != event.title {
                        Text(event.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text(statusLabel(event.status))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(event.status).opacity(0.14), in: Capsule())
                    .foregroundStyle(statusColor(event.status))
            }

            HStack(spacing: 14) {
                metadata("Due", event.dueDate.formatted(date: .abbreviated, time: .shortened))
                metadata("Source", sourceLabel(event.createdSource))
                metadata("Latest", eventLabel(event.eventType))
            }

            HStack(spacing: 14) {
                metadata("Created", event.createdAt.formatted(date: .abbreviated, time: .shortened))
                metadata("Updated", event.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding(.vertical, 8)
    }

    private func metadata(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private func statusLabel(_ status: ReminderStatus) -> String {
        switch status {
        case .pending:
            return "Pending"
        case .due:
            return "Due"
        case .completed:
            return "Completed"
        case .snoozed:
            return "Snoozed"
        case .rescheduled:
            return "Rescheduled"
        case .cancelled:
            return "Cancelled"
        }
    }

    private func sourceLabel(_ source: ReminderCreatedSource) -> String {
        switch source {
        case .rightClick, .manual, .system:
            return "Right-click"
        case .menuBar:
            return "Menu Bar"
        case .chat:
            return "Chat"
        case .todo:
            return "Todo"
        case .pomodoro:
            return "Pomodoro"
        }
    }

    private func eventLabel(_ event: ReminderHistoryEventType) -> String {
        switch event {
        case .created:
            return "Created"
        case .dueTriggered:
            return "Due triggered"
        case .completed:
            return "Completed"
        case .snoozed:
            return "Snoozed"
        case .rescheduled:
            return "Rescheduled"
        case .cancelled:
            return "Cancelled"
        case .deleted:
            return "Deleted"
        }
    }

    private func statusColor(_ status: ReminderStatus) -> Color {
        switch status {
        case .pending:
            return .blue
        case .due:
            return .orange
        case .completed:
            return .green
        case .snoozed:
            return .purple
        case .rescheduled:
            return .indigo
        case .cancelled:
            return .red
        }
    }
}
