//
//  WeeklyCodingMetricsSummary.swift
//  Milo
//
//  PRIVACY: Weekly summary is aggregated from local daily records only.
//  No data is uploaded to any server.
//

import Foundation

struct WeeklyCodingMetricsSummary: Codable, Equatable {
    var weekStartDate: Date
    var weekEndDate: Date

    var totalCodingSeconds: Int
    var averageCodingSecondsPerActiveDay: Int
    var activeDays: Int

    var mostProductiveDay: DailyCodingMetricsRecord?

    var topLanguage: String?
    var topProject: String?
    var topEditor: String?

    var languageBreakdown: [CategoryBreakdown]
    var projectBreakdown: [CategoryBreakdown]
    var editorBreakdown: [CategoryBreakdown]

    var totalLOC: LOCSummary
    var totalSessions: Int

    var completedPomodoros: Int
    var skippedBreaks: Int
    var totalTodosCreated: Int
    var totalTodosCompleted: Int

    var dailyRecords: [DailyCodingMetricsRecord]

    var insights: [WeeklyInsight]

    var sourceLabel: String
    var generatedAt: Date

    var totalCodingMinutes: Int { totalCodingSeconds / 60 }
    var averageCodingMinutesPerActiveDay: Int { averageCodingSecondsPerActiveDay / 60 }

    static let empty = WeeklyCodingMetricsSummary(
        weekStartDate: Date(),
        weekEndDate: Date(),
        totalCodingSeconds: 0,
        averageCodingSecondsPerActiveDay: 0,
        activeDays: 0,
        mostProductiveDay: nil,
        topLanguage: nil,
        topProject: nil,
        topEditor: nil,
        languageBreakdown: [],
        projectBreakdown: [],
        editorBreakdown: [],
        totalLOC: .empty,
        totalSessions: 0,
        completedPomodoros: 0,
        skippedBreaks: 0,
        totalTodosCreated: 0,
        totalTodosCompleted: 0,
        dailyRecords: [],
        insights: [],
        sourceLabel: "Local",
        generatedAt: Date()
    )
}

struct WeeklyInsight: Identifiable, Codable, Equatable {
    var id: String { title }
    let icon: String
    let title: String
    let message: String
    let severity: InsightSeverity
}

enum InsightSeverity: String, Codable, Equatable {
    case positive
    case neutral
    case warning
}
