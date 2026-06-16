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

    var mostProductiveDay: DailyCodingMetricsRecord?

    var topLanguage: String?
    var topProject: String?
    var topEditor: String?

    var totalLOC: LOCSummary
    var totalSessions: Int

    var dailyRecords: [DailyCodingMetricsRecord]

    var sourceLabel: String
    var generatedAt: Date

    static let empty = WeeklyCodingMetricsSummary(
        weekStartDate: Date(),
        weekEndDate: Date(),
        totalCodingSeconds: 0,
        averageCodingSecondsPerActiveDay: 0,
        mostProductiveDay: nil,
        topLanguage: nil,
        topProject: nil,
        topEditor: nil,
        totalLOC: .empty,
        totalSessions: 0,
        dailyRecords: [],
        sourceLabel: "Local",
        generatedAt: Date()
    )
}
