//
//  ProjectActivitySnapshot.swift
//  Milo
//
//  PRIVACY: Stores only aggregated file activity metadata.
//  No source code content is stored or uploaded.
//

import Foundation

struct ProjectActivitySnapshot: Codable, Equatable {
    var dateKey: String
    var activeProjectName: String?
    var activeProjectPath: String?
    var lastActivityAt: Date?
    var changedFileCountToday: Int
    var topLanguageToday: String?
    var recentLanguages: [String: Int]
    var recentEvents: [ProjectFileEvent]
    var locSummary: LOCSummary
    var lastUpdatedAt: Date

    static func empty(for date: Date = Date()) -> ProjectActivitySnapshot {
        ProjectActivitySnapshot(
            dateKey: makeDateKey(date),
            activeProjectName: nil,
            activeProjectPath: nil,
            lastActivityAt: nil,
            changedFileCountToday: 0,
            topLanguageToday: nil,
            recentLanguages: [:],
            recentEvents: [],
            locSummary: .empty,
            lastUpdatedAt: Date()
        )
    }

    static func makeDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
