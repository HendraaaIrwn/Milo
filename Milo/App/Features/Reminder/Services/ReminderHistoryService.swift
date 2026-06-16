//
//  ReminderHistoryService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Combine
import Foundation

@MainActor
final class ReminderHistoryService: ObservableObject {
    @Published private(set) var events: [MiloReminderHistoryEvent] = []

    private let storage: MiloLocalStorageService

    convenience init() {
        self.init(storage: .shared)
    }

    init(storage: MiloLocalStorageService) {
        self.storage = storage
        load()
    }

    func load() {
        events = storage.load(
            [MiloReminderHistoryEvent].self,
            forKey: MiloStorageKeys.reminderHistoryEvents,
            defaultValue: []
        )
        sortEvents()
    }

    func save() {
        storage.save(events, forKey: MiloStorageKeys.reminderHistoryEvents)
    }

    func clearHistory() {
        events.removeAll()
        save()
    }

    func recordCreated(_ reminder: MiloReminder) {
        record(reminder, eventType: .created)
    }

    func recordDueTriggered(_ reminder: MiloReminder) {
        record(reminder, eventType: .dueTriggered)
    }

    func recordCompleted(_ reminder: MiloReminder) {
        record(reminder, eventType: .completed)
    }

    func recordSnoozed(_ reminder: MiloReminder, minutes: Int, newDueDate: Date) {
        record(reminder, eventType: .snoozed, dueDate: newDueDate, note: "Snoozed \(minutes) min")
    }

    func recordRescheduled(_ reminder: MiloReminder, oldDueDate: Date, newDueDate: Date) {
        record(reminder, eventType: .rescheduled, dueDate: newDueDate, note: "Rescheduled")
    }

    func recordCancelled(_ reminder: MiloReminder) {
        record(reminder, eventType: .cancelled)
    }

    func recordDeleted(_ reminder: MiloReminder) {
        record(reminder, eventType: .deleted)
    }

    func eventsByReminder() -> [UUID: [MiloReminderHistoryEvent]] {
        Dictionary(grouping: events, by: \.reminderID)
    }

    func latestEvent(for reminderID: UUID) -> MiloReminderHistoryEvent? {
        events.first { $0.reminderID == reminderID }
    }

    private func record(
        _ reminder: MiloReminder,
        eventType: ReminderHistoryEventType,
        dueDate: Date? = nil,
        note: String? = nil
    ) {
        // MILO Reminder History is local-only.
        // For chat reminders, MILO stores only the final reminder message and metadata.
        // MILO does not store full chat transcripts or upload reminder data.
        let event = MiloReminderHistoryEvent(
            reminderID: reminder.id,
            title: reminder.title,
            message: reminder.message,
            dueDate: dueDate ?? reminder.dueDate,
            status: reminder.status,
            createdSource: reminder.createdSource,
            createdAt: reminder.createdAt,
            updatedAt: reminder.updatedAt,
            eventType: eventType,
            note: note
        )

        events.append(event)
        sortEvents()
        save()
    }

    private func sortEvents() {
        events.sort { lhs, rhs in
            lhs.eventDate > rhs.eventDate
        }
    }
}
