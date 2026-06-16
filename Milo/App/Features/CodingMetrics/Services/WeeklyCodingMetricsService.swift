//
//  WeeklyCodingMetricsService.swift
//  Milo
//
//  PRIVACY: Weekly summary is aggregated from local daily records only.
//  No data is uploaded to any server.
//

import Combine
import Foundation
import OSLog

@MainActor
final class WeeklyCodingMetricsService: ObservableObject {
    @Published private(set) var weeklySummary: WeeklyCodingMetricsSummary = .empty

    private let storage: MiloLocalStorageService

    private let logger = Logger(
        subsystem: "com.milo",
        category: "WeeklyCodingMetrics"
    )

    convenience init() {
        self.init(storage: .shared)
    }

    init(storage: MiloLocalStorageService) {
        self.storage = storage
        refreshWeeklySummary()
    }

    func refreshWeeklySummary(
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let records = storage.load(
            [DailyCodingMetricsRecord].self,
            forKey: MiloStorageKeys.dailyCodingMetricsRecords,
            defaultValue: []
        )

        let weekInterval = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        )

        guard let weekInterval else {
            weeklySummary = .empty
            return
        }

        let weeklyRecords = records.filter { record in
            record.date >= weekInterval.start &&
            record.date < weekInterval.end
        }
        .sorted { $0.date < $1.date }

        weeklySummary = buildSummary(
            records: weeklyRecords,
            weekStart: weekInterval.start,
            weekEnd: weekInterval.end
        )

        storage.save(
            weeklySummary,
            forKey: MiloStorageKeys.weeklyCodingSummaryCache
        )

        logger.debug("WeeklyCodingMetrics: refreshed summary with \(weeklyRecords.count) daily records")
    }

    func resetWeeklyLocalStats(
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let weekInterval = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        )

        guard let weekInterval else { return }

        var records = storage.load(
            [DailyCodingMetricsRecord].self,
            forKey: MiloStorageKeys.dailyCodingMetricsRecords,
            defaultValue: []
        )

        records.removeAll { record in
            record.date >= weekInterval.start &&
            record.date < weekInterval.end
        }

        storage.save(
            records,
            forKey: MiloStorageKeys.dailyCodingMetricsRecords
        )

        refreshWeeklySummary(now: now, calendar: calendar)
    }

    private func buildSummary(
        records: [DailyCodingMetricsRecord],
        weekStart: Date,
        weekEnd: Date
    ) -> WeeklyCodingMetricsSummary {
        let totalSeconds = records.reduce(0) {
            $0 + $1.codingSeconds
        }

        let activeDays = records.filter {
            $0.codingSeconds > 0
        }

        let averageSeconds = activeDays.isEmpty
            ? 0
            : totalSeconds / activeDays.count

        let mostProductiveDay = records.max {
            $0.codingSeconds < $1.codingSeconds
        }

        let totalAdded = records.reduce(0) {
            $0 + $1.locSummary.linesAdded
        }

        let totalDeleted = records.reduce(0) {
            $0 + $1.locSummary.linesDeleted
        }

        let totalSessions = records.reduce(0) {
            $0 + $1.sessionCount
        }

        let topLanguage = topKey(
            from: records.flatMap { record in
                record.languageSeconds.map { ($0.key, $0.value) }
            }
        )

        let topProject = topKey(
            from: records.flatMap { record in
                record.projectSeconds.map { ($0.key, $0.value) }
            }
        )

        let topEditor = topKey(
            from: records.flatMap { record in
                record.editorSeconds.map { ($0.key, $0.value) }
            }
        )

        return WeeklyCodingMetricsSummary(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            totalCodingSeconds: totalSeconds,
            averageCodingSecondsPerActiveDay: averageSeconds,
            mostProductiveDay: mostProductiveDay,
            topLanguage: topLanguage,
            topProject: topProject,
            topEditor: topEditor,
            totalLOC: LOCSummary(
                linesAdded: totalAdded,
                linesDeleted: totalDeleted
            ),
            totalSessions: totalSessions,
            dailyRecords: records,
            sourceLabel: "Local",
            generatedAt: Date()
        )
    }

    private func topKey(
        from pairs: [(String, Int)]
    ) -> String? {
        var totals: [String: Int] = [:]

        for pair in pairs {
            totals[pair.0, default: 0] += pair.1
        }

        return totals.max {
            $0.value < $1.value
        }?.key
    }
}
