//
//  MiloResponseHistory.swift
//  Milo
//

import Foundation

struct MiloResponseHistory: Codable {
    var recentlyShownTemplateIDs: [String] = []
    var recentlyShownTexts: [String] = []
    var recentIntents: [MiloResponseIntent] = []
    var lastIntent: MiloResponseIntent?
    var lastShownAt: Date?

    mutating func record(templateID: String, text: String, intent: MiloResponseIntent) {
        recentlyShownTemplateIDs.insert(templateID, at: 0)
        recentlyShownTexts.insert(text, at: 0)
        recentIntents.insert(intent, at: 0)

        recentlyShownTemplateIDs = Array(recentlyShownTemplateIDs.prefix(20))
        recentlyShownTexts = Array(recentlyShownTexts.prefix(20))
        recentIntents = Array(recentIntents.prefix(20))

        lastIntent = intent
        lastShownAt = Date()
    }

    func hasRecentlyShown(templateID: String) -> Bool {
        recentlyShownTemplateIDs.contains(templateID)
    }

    func hasRecentlyShownText(_ text: String) -> Bool {
        recentlyShownTexts.contains(text)
    }

    var consecutiveSameIntentCount: Int {
        guard let last = recentIntents.first else { return 0 }
        var count = 0
        for intent in recentIntents {
            if intent == last { count += 1 } else { break }
        }
        return count
    }
}
