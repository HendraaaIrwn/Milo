//
//  MiloResponseHistory.swift
//  Milo
//

import Foundation

struct MiloResponseHistory: Codable {
    var recentlyShownTemplateIDs: [String] = []
    var recentlyShownTexts: [String] = []
    var lastIntent: MiloResponseIntent?
    var lastShownAt: Date?

    mutating func record(templateID: String, text: String, intent: MiloResponseIntent) {
        recentlyShownTemplateIDs.insert(templateID, at: 0)
        recentlyShownTexts.insert(text, at: 0)
        recentlyShownTemplateIDs = Array(recentlyShownTemplateIDs.prefix(12))
        recentlyShownTexts = Array(recentlyShownTexts.prefix(12))
        lastIntent = intent
        lastShownAt = Date()
    }

    func hasRecentlyShown(templateID: String) -> Bool {
        recentlyShownTemplateIDs.contains(templateID)
    }

    func hasRecentlyShownText(_ text: String) -> Bool {
        recentlyShownTexts.contains(text)
    }
}
