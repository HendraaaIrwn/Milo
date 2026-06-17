//
//  WeeklyCodingMetricsService.swift
//  Milo
//
//  PRIVACY: Weekly summary is aggregated from local daily records, pomodoro stats,
//  and todo counts. No data is uploaded to any server.
//

import Combine
import Foundation
import OSLog

@MainActor
final class WeeklyCodingMetricsService: ObservableObject {
    @Published private(set) var weeklySummary: WeeklyCodingMetricsSummary = .empty

    private let storage: MiloLocalStorageService
    private let pomodoroService: PomodoroService?
    private let todoService: TodoService?

    private let logger = Logger(
        subsystem: "com.milo",
        category: "WeeklyCodingMetrics"
    )

    convenience init() {
        self.init(storage: .shared)
    }

    init(
        storage: MiloLocalStorageService,
        pomodoroService: PomodoroService? = nil,
        todoService: TodoService? = nil
    ) {
        self.storage = storage
        self.pomodoroService = pomodoroService
        self.todoService = todoService
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

        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now)
        guard let weekInterval else {
            weeklySummary = .empty
            return
        }

        let weeklyRecords = records.filter { record in
            record.date >= weekInterval.start && record.date < weekInterval.end
        }.sorted { $0.date < $1.date }

        weeklySummary = buildSummary(
            records: weeklyRecords,
            weekStart: weekInterval.start,
            weekEnd: weekInterval.end
        )

        storage.save(weeklySummary, forKey: MiloStorageKeys.weeklyCodingSummaryCache)
        logger.debug("WeeklyCodingMetrics: refreshed summary with \(weeklyRecords.count) daily records")
    }

    func resetWeeklyLocalStats(
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now)
        guard let weekInterval else { return }

        var records = storage.load(
            [DailyCodingMetricsRecord].self,
            forKey: MiloStorageKeys.dailyCodingMetricsRecords,
            defaultValue: []
        )

        records.removeAll { record in
            record.date >= weekInterval.start && record.date < weekInterval.end
        }

        storage.save(records, forKey: MiloStorageKeys.dailyCodingMetricsRecords)
        refreshWeeklySummary(now: now, calendar: calendar)
    }

    private func buildSummary(
        records: [DailyCodingMetricsRecord],
        weekStart: Date,
        weekEnd: Date
    ) -> WeeklyCodingMetricsSummary {
        let totalSeconds = records.reduce(0) { $0 + $1.codingSeconds }
        let activeDayRecords = records.filter { $0.codingSeconds > 0 }
        let activeDays = activeDayRecords.count
        let averageSeconds = activeDays > 0 ? totalSeconds / activeDays : 0
        let mostProductiveDay = records.max(by: { $0.codingSeconds < $1.codingSeconds })
        let totalAdded = records.reduce(0) { $0 + $1.locSummary.linesAdded }
        let totalDeleted = records.reduce(0) { $0 + $1.locSummary.linesDeleted }
        let totalSessions = records.reduce(0) { $0 + $1.sessionCount }

        let topLanguage = topKey(from: records.flatMap { $0.languageSeconds.map { ($0.key, $0.value) } })
        let topProject = topKey(from: records.flatMap { $0.projectSeconds.map { ($0.key, $0.value) } })
        let topEditor = topKey(from: records.flatMap { $0.editorSeconds.map { ($0.key, $0.value) } })

        let languageBreakdown = breakdown(from: records, keyPath: \.languageSeconds)
        let projectBreakdown = breakdown(from: records, keyPath: \.projectSeconds)
        let editorBreakdown = breakdown(from: records, keyPath: \.editorSeconds)

        let pomStats = pomodoroService?.stats
        let completedPomodoros = pomStats?.pomodorosToday ?? 0
        let skippedBreaks = pomStats?.skippedBreaksToday ?? 0
        let totalTodosCreated = todoService?.todos.count ?? 0
        let totalTodosCompleted = todoService?.todos.filter { $0.status == .done }.count ?? 0

        let summary = WeeklyCodingMetricsSummary(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            totalCodingSeconds: totalSeconds,
            averageCodingSecondsPerActiveDay: averageSeconds,
            activeDays: activeDays,
            mostProductiveDay: mostProductiveDay,
            topLanguage: topLanguage,
            topProject: topProject,
            topEditor: topEditor,
            languageBreakdown: languageBreakdown,
            projectBreakdown: projectBreakdown,
            editorBreakdown: editorBreakdown,
            totalLOC: LOCSummary(
                linesAdded: totalAdded,
                linesDeleted: totalDeleted,
                filesChanged: 0,
                status: .ready,
                lastUpdatedAt: Date()
            ),
            totalSessions: totalSessions,
            completedPomodoros: completedPomodoros,
            skippedBreaks: skippedBreaks,
            totalTodosCreated: totalTodosCreated,
            totalTodosCompleted: totalTodosCompleted,
            dailyRecords: records,
            insights: [],
            sourceLabel: "Local",
            generatedAt: Date()
        )

        var result = summary
        result.insights = generateInsights(from: result)
        return result
    }

    private func breakdown(
        from records: [DailyCodingMetricsRecord],
        keyPath: KeyPath<DailyCodingMetricsRecord, [String: Int]>
    ) -> [CategoryBreakdown] {
        var totals: [String: Int] = [:]
        for record in records {
            let dict = record[keyPath: keyPath]
            for (key, seconds) in dict {
                totals[key, default: 0] += seconds
            }
        }
        let totalSeconds = totals.values.reduce(0, +)
        guard totalSeconds > 0 else { return [] }
        return totals
            .map { (name, seconds) in
                CategoryBreakdown(name: name, minutes: seconds / 60, percentage: Double(seconds) / Double(totalSeconds) * 100)
            }
            .sorted { $0.minutes > $1.minutes }
    }

    private func topKey(from pairs: [(String, Int)]) -> String? {
        var totals: [String: Int] = [:]
        for pair in pairs { totals[pair.0, default: 0] += pair.1 }
        return totals.max(by: { $0.value < $1.value })?.key
    }

    private func generateInsights(from summary: WeeklyCodingMetricsSummary) -> [WeeklyInsight] {
        var insights: [WeeklyInsight] = []

        if summary.totalCodingMinutes >= 600 {
            insights.append(WeeklyInsight(icon: "flame.fill", title: "Power Week", message: "\(formatMinutes(summary.totalCodingMinutes)) of coding this week. That's serious momentum.", severity: .positive))
        } else if summary.totalCodingMinutes >= 300 {
            insights.append(WeeklyInsight(icon: "chart.line.uptrend.xyaxis", title: "Solid Week", message: "\(formatMinutes(summary.totalCodingMinutes)) of coding. Consistent effort pays off.", severity: .positive))
        }

        if summary.activeDays >= 5, summary.totalCodingMinutes > 0 {
            insights.append(WeeklyInsight(icon: "calendar.badge.checkmark", title: "Consistent", message: "You coded on \(summary.activeDays) days this week. Great rhythm.", severity: .positive))
        } else if summary.activeDays >= 3 {
            insights.append(WeeklyInsight(icon: "calendar", title: "Steady Pace", message: "\(summary.activeDays) active days. Find your groove.", severity: .neutral))
        }

        if let best = summary.mostProductiveDay, best.codingSeconds > 0 {
            let dayName = best.date.formatted(Date.FormatStyle().weekday(.wide))
            insights.append(WeeklyInsight(icon: "sparkles", title: "Best Day: \(dayName)", message: "\(formatMinutes(best.codingSeconds)) on \(dayName). Your peak coding window.", severity: .positive))
        }

        if let lang = summary.topLanguage {
            insights.append(WeeklyInsight(icon: "chevron.left.forwardslash.chevron.right", title: "Language of the Week", message: "\(lang) dominated your coding time. Tiny wizard mode engaged.", severity: .neutral))
        }

        if summary.skippedBreaks > 0 {
            insights.append(WeeklyInsight(icon: "figure.walk", title: "Skipped Breaks", message: "You skipped \(summary.skippedBreaks) break\(summary.skippedBreaks > 1 ? "s" : ""). Future-you recommends fewer heroic chair sessions.", severity: .warning))
        }

        if summary.completedPomodoros >= 5 {
            insights.append(WeeklyInsight(icon: "timer", title: "Pomodoro Champ", message: "\(summary.completedPomodoros) pomodoros completed. The tiny tomato salutes you.", severity: .positive))
        }

        if summary.totalTodosCompleted > 0 {
            insights.append(WeeklyInsight(icon: "checklist", title: "Getting Things Done", message: "\(summary.totalTodosCompleted) todos marked complete. Tasks fear your consistency.", severity: .positive))
        }

        if insights.isEmpty {
            insights.append(WeeklyInsight(icon: "hand.wave", title: "Week Starting", message: "Start coding and MILO will find patterns in your rhythm.", severity: .neutral))
        }

        return insights
    }

    private func formatMinutes(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
