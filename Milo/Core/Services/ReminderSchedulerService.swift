//
//  ReminderSchedulerService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

@MainActor
final class ReminderSchedulerService {
    private let reminderService: ReminderService
    private let miloStateStore: MiloStateStore

    private var timerTask: Task<Void, Never>?
    private var bubbleHideTask: Task<Void, Never>?

    init(reminderService: ReminderService, miloStateStore: MiloStateStore) {
        self.reminderService = reminderService
        self.miloStateStore = miloStateStore
    }

    func start() {
        stop()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.checkDueReminders()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        bubbleHideTask?.cancel()
        bubbleHideTask = nil
    }

    private func checkDueReminders() {
        guard let reminder = reminderService.dueReminders().first else { return }
        triggerReminder(reminder)
    }

    private func triggerReminder(_ reminder: MiloReminder) {
        reminderService.markDone(id: reminder.id)
        miloStateStore.showReminderBubble(reminder.message)
        ReminderSoundEngine.shared.playReminderSound(mode: reminder.soundMode)
        scheduleHideBubble()
    }

    private func scheduleHideBubble() {
        bubbleHideTask?.cancel()

        bubbleHideTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            guard !Task.isCancelled else { return }
            self?.miloStateStore.hideReminderBubble()
        }
    }
}
