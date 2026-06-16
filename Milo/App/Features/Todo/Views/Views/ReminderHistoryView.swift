//
//  ReminderHistoryView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct ReminderHistoryView: View {
    @ObservedObject var historyService: ReminderHistoryService
    @State private var filter: ReminderHistoryFilter = .all
    @State private var showClearConfirmation = false

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

    private var filteredEvents: [MiloReminderHistoryEvent] {
        latestEvents.filter { filter.includes($0) }
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Reminder History",
            subtitle: "Review reminder activity, snoozes, completions, and chat-created reminders.",
            systemImage: "clock.arrow.circlepath",
            primaryActionTitle: !filteredEvents.isEmpty ? "Clear" : nil,
            primaryActionSystemImage: "trash",
            primaryAction: !filteredEvents.isEmpty ? { showClearConfirmation = true } : nil
        ) {
            MiloPanelCardView(
                title: "Filters",
                subtitle: "Narrow reminders by status or creation source.",
                trailing: AnyView(
                    MiloStatusPillView(title: "\(filteredEvents.count) items", systemImage: "tray.full.fill", tone: .info)
                )
            ) {
                Picker("Filter", selection: $filter) {
                    ForEach(ReminderHistoryFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }

            MiloPanelCardView(
                title: "History List",
                subtitle: "Latest event per reminder. Long messages stay readable."
            ) {
                if filteredEvents.isEmpty {
                    MiloEmptyStateView(
                        systemImage: "clock.badge.questionmark",
                        title: emptyTitle,
                        message: "Completed, snoozed, rescheduled, and due reminders will appear here."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEvents) { event in
                            ReminderHistoryStyledRowView(event: event)
        }
        .confirmationDialog("Clear reminder history?", isPresented: $showClearConfirmation) {
            Button("Clear All History", role: .destructive) {
                historyService.clearHistory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all \(filteredEvents.count) reminder history events. This cannot be undone.")
        }
    }
                }
            }
        } footer: {
            MiloPanelFooterView(
                message: "Reminder history is stored locally.",
                statusTitle: filter.title,
                statusTone: .neutral
            )
        }
    }

    private var emptyTitle: String {
        filter == .all ? "No reminder history yet." : "No \(filter.title.lowercased()) reminders yet."
    }
}

private enum ReminderHistoryFilter: String, CaseIterable, Identifiable {
    case all
    case pending
    case done
    case snoozed
    case chat
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .pending:
            return "Pending"
        case .done:
            return "Done"
        case .snoozed:
            return "Snoozed"
        case .chat:
            return "Chat"
        case .manual:
            return "Manual"
        }
    }

    func includes(_ event: MiloReminderHistoryEvent) -> Bool {
        switch self {
        case .all:
            return true
        case .pending:
            return event.status == .pending || event.status == .due
        case .done:
            return event.status == .completed
        case .snoozed:
            return event.status == .snoozed || event.eventType == .snoozed
        case .chat:
            return event.createdSource == .chat
        case .manual:
            return event.createdSource == .rightClick || event.createdSource == .manual || event.createdSource == .menuBar
        }
    }
}

private struct ReminderHistoryStyledRowView: View {
    let event: MiloReminderHistoryEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(statusToneColor.opacity(0.12))

                Image(systemName: statusIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(statusToneColor)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .firstTextBaseline) {
                    Text(event.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .lineLimit(1)

                    Spacer()

                    Menu {
                        Button("View Details") {}
                            .disabled(true)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .menuStyle(.borderlessButton)
                }

//                Text(event.message)
//                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                    .foregroundStyle(.secondary)
//                    .lineLimit(2)

                HStack(spacing: 8) {
                    MiloStatusPillView(title: statusLabel, systemImage: "circle.fill", tone: statusTone)
                    MiloStatusPillView(title: sourceLabel, systemImage: "person.crop.circle.badge.checkmark", tone: .neutral)
                    MiloStatusPillView(title: eventLabel, systemImage: "arrow.triangle.2.circlepath", tone: .info)
                }

                Text("Due \(event.dueDate.formatted(date: .abbreviated, time: .shortened)) • Updated \(event.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.72))
        )
    }

    private var statusIcon: String {
        switch event.status {
        case .pending:
            return "bell.fill"
        case .due:
            return "bell.badge.fill"
        case .completed:
            return "checkmark.circle.fill"
        case .snoozed:
            return "moon.zzz.fill"
        case .rescheduled:
            return "calendar.badge.clock"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }

    private var statusLabel: String {
        switch event.status {
        case .pending:
            return "Pending"
        case .due:
            return "Due"
        case .completed:
            return "Done"
        case .snoozed:
            return "Snoozed"
        case .rescheduled:
            return "Rescheduled"
        case .cancelled:
            return "Cancelled"
        }
    }

    private var statusTone: MiloStatusPillView.Tone {
        switch event.status {
        case .pending, .rescheduled:
            return .info
        case .due, .snoozed:
            return .warning
        case .completed:
            return .success
        case .cancelled:
            return .danger
        }
    }

    private var statusToneColor: Color {
        switch statusTone {
        case .success:
            return .green
        case .warning:
            return .orange
        case .danger:
            return .red
        case .neutral:
            return .secondary
        case .info:
            return .blue
        }
    }

    private var sourceLabel: String {
        switch event.createdSource {
        case .rightClick, .manual, .system:
            return "Manual"
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

    private var eventLabel: String {
        switch event.eventType {
        case .created:
            return "Created"
        case .dueTriggered:
            return "Triggered"
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
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    ReminderHistoryView(historyService: ReminderHistoryService())
}
#endif
