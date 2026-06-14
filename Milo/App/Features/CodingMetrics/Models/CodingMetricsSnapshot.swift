//
//  CodingMetricsSnapshot.swift
//  Milo
//
//  PRIVACY: Snapshot stores aggregated metrics only. No source code content is ever included.
//

import Foundation

struct CodingMetricsSnapshot: Codable, Equatable {
    var dateKey: String
    var codingSecondsToday: Int
    var currentSessionSeconds: Int
    var topLanguage: String?
    var topProject: String?
    var topEditor: String?
    var locToday: LOCSummary
    var languageMetrics: [CodingLanguageMetric]
    var projectMetrics: [CodingProjectMetric]
    var editorMetrics: [EditorUsageMetric]
    var sessions: [CodingSession]
    var lastUpdatedAt: Date

    static func empty(for date: Date = Date()) -> CodingMetricsSnapshot {
        CodingMetricsSnapshot(
            dateKey: makeDateKey(date),
            codingSecondsToday: 0,
            currentSessionSeconds: 0,
            topLanguage: nil,
            topProject: nil,
            topEditor: nil,
            locToday: .empty,
            languageMetrics: [],
            projectMetrics: [],
            editorMetrics: [],
            sessions: [],
            lastUpdatedAt: Date()
        )
    }

    static func makeDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
