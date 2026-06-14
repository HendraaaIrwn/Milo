//
//  MiloReactionLineProvider.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

struct MiloReactionLineProvider {
    static let roastLines: [String] = [
        "Bug lagi? Skill issue. Kidding.",
        "You saved the file 14 times. Milo respects the anxiety.",
        "That code compiles in your imagination.",
        "Milo saw that TODO from last week.",
        "The compiler is not angry, just disappointed.",
        "You call it refactor, Git calls it crime scene.",
        "Bro is fighting semicolons like a final boss.",
        "This bug has paid rent in your project.",
        "Milo believes in you. The linter does not.",
        "That function is getting a little too confident."
    ]

    static let encourageLines: [String] = [
        "Keep going. One bug at a time.",
        "Tiny progress is still progress.",
        "You are closer than you think.",
        "Milo thinks this commit might be the one.",
        "Take a breath. You got this.",
        "Clean code starts with messy attempts.",
        "The bug is scared. Keep typing.",
        "You are building something cool.",
        "Focus mode activated. Let's cook.",
        "Small steps, big ship."
    ]

    static func randomLine() -> String {
        Self.allLines.randomElement() ?? "Milo is watching your code."
    }

    static func randomLine(excluding currentLine: String?) -> String {
        guard let currentLine else { return randomLine() }

        let candidates = allLines.filter { $0 != currentLine }
        return candidates.randomElement() ?? randomLine()
    }

    private static var allLines: [String] {
        roastLines + encourageLines
    }
}
