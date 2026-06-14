//
//  MiloTypingDialogProvider.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct MiloTypingDialogProvider {
    static func randomLine(for intensity: TypingIntensity) -> String {
        switch intensity {
        case .inactive:
            idleLines.randomElement() ?? "Milo is waiting."
        case .slow:
            slowTypingLines.randomElement() ?? "Slow typing detected."
        case .normal:
            normalTypingLines.randomElement() ?? "Milo sees steady progress."
        case .fast:
            fastTypingLines.randomElement() ?? "Fast typing detected."
        }
    }

    private static let idleLines = [
        "Milo is waiting for the next bug.",
        "Idle mode. Suspiciously peaceful.",
        "No typing. Either thinking or staring into the void."
    ]

    private static let slowTypingLines = [
        "Slow typing. Careful debugging energy.",
        "Milo thinks you are negotiating with the compiler.",
        "Tiny keystrokes. Big brain loading.",
        "This feels like naming a variable. Painful, but important.",
        "Slow and steady. Probably a tricky bug.",
        "Milo respects the careful typing.",
        "You’re typing like every character has legal consequences.",
        "Hmm. This has refactor energy.",
        "Milo senses deep thought and mild confusion.",
        "One key at a time. The bug fears patience."
    ]

    private static let normalTypingLines = [
        "Nice rhythm. Code is happening.",
        "Milo sees steady progress.",
        "That typing sounds productive.",
        "You’re in the zone. Milo approves.",
        "This might actually compile.",
        "Milo thinks you’re building something cool.",
        "Solid typing rhythm. Keep cooking.",
        "Feature mode detected.",
        "Commit-worthy energy is forming.",
        "Milo believes this function has potential."
    ]

    private static let fastTypingLines = [
        "You’re typing like the bug owes you money.",
        "Fast typing detected. Genius mode or panic mode.",
        "Milo sees keyboard violence.",
        "Bro is fighting the compiler in real time.",
        "That typing speed is either confidence or fear.",
        "Milo thinks you just found the fix.",
        "Careful. The keyboard has feelings.",
        "You are summoning a function at dangerous speed.",
        "Refactor storm detected.",
        "Milo is impressed and slightly concerned."
    ]
}
