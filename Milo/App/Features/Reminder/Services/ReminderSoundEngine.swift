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
        guard reminderSoundEnabled else { return }

        switch mode {
        case .silent:
            return
        case .meow, .softPing:
            NSSound(named: "Pop")?.play()
        case .mumble:
            MiloMumbleEngine.shared.speakName()
        case .reminderBell, .urgent:
            NSSound(named: "Glass")?.play()
        }
    }

    private var reminderSoundEnabled: Bool {
        guard UserDefaults.standard.object(forKey: MiloStorageKeys.reminderSoundEnabled) != nil else {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.reminderSoundEnabled)
    }
}
