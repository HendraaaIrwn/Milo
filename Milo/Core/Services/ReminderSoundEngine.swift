//
//  ReminderSoundEngine.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import AppKit

@MainActor
final class ReminderSoundEngine {
    static let shared = ReminderSoundEngine()

    private init() {}

    func playReminderSound(mode: ReminderSoundMode = .reminderBell) {
        guard isReminderSoundEnabled else { return }

        switch mode {
        case .silent:
            return
        case .reminderBell, .mumble:
            NSSound(named: "Glass")?.play()
        case .softPing, .meow:
            NSSound(named: "Pop")?.play()
        case .urgent:
            NSSound(named: "Funk")?.play()
        }
    }

    private var isReminderSoundEnabled: Bool {
        guard UserDefaults.standard.object(forKey: MiloStorageKeys.reminderSoundEnabled) != nil else {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.reminderSoundEnabled)
    }
}
