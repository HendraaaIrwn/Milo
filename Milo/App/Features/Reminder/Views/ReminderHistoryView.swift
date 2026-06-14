//
//  ReminderHistoryView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct ReminderHistoryView: View {
    @ObservedObject var historyService: ReminderHistoryService

    private var latestEvents: [MiloReminderHistoryEvent] {
        historyService.eventsByReminder().compactMap { _, events in
            events.sorted { $0.eventDate > $1.eventDate }.first
        }
        .sorted { lhs, rhs in
            if lhs.updatedAt == rhs.updatedAt {
                return lhs.eventDate > rhs.eventDate
            }

            return lhs.updatedAt > rhs.updatedAt
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reminder History")
                    .font(.title2.weight(.semibold))

                Spacer()

                Text("\(latestEvents.count) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if latestEvents.isEmpty {
                ContentUnavailableView(
                    "No reminder history yet.",
                    systemImage: "clock.badge.questionmark",
                    description: Text("Completed, snoozed, rescheduled, and due reminders will appear here.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(latestEvents) { event in
                    ReminderHistoryRowView(event: event)
                        .listRowSeparator(.visible)
                }
                .listStyle(.inset)
            }
        }
        .padding(20)
        .frame(width: 680, height: 520)
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    ReminderHistoryView(historyService: ReminderHistoryService())
}
#endif
