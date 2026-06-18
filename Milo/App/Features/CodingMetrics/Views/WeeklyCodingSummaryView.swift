//
//  WeeklyCodingSummaryView.swift
//  Milo
//

import SwiftUI

struct WeeklyCodingSummaryView: View {
    @ObservedObject var weeklyService: WeeklyCodingMetricsService

    private var summary: WeeklyCodingMetricsSummary {
        weeklyService.weeklySummary
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Weekly Coding Summary",
            subtitle: "Your coding snapshot — focus, languages, projects, and insights.",
            systemImage: "calendar.badge.clock",
            primaryActionTitle: "Refresh",
            primaryActionSystemImage: "arrow.clockwise",
            primaryAction: { weeklyService.refreshWeeklySummary() }
        ) {
            weekRangeCard

            if summary.totalCodingSeconds > 0 {
                heroCards
                dailyActivityCard
                languagesAndProjectsRow
                focusPomodoroSection
                insightsCard
            } else {
                MiloPanelCardView(title: "No Activity", subtitle: "No coding data tracked yet this week.") {
                    MiloEmptyStateView(
                        systemImage: "chart.bar.doc.horizontal",
                        title: "No coding activity tracked this week yet.",
                        message: "MILO needs a watched project folder or local coding metrics to build your weekly summary.",
                        buttonTitle: "Open File Watcher Settings",
                        buttonSystemImage: "folder.badge.gearshape",
                        action: {}
                    )
                }
            }

            MiloPanelCardView(title: "Daily Breakdown", subtitle: "Card-like day rows with time, sessions, project, language, and LOC.") {
                if summary.dailyRecords.isEmpty {
                    MiloEmptyStateView(
                        systemImage: "calendar.badge.plus",
                        title: "No daily records yet.",
                        message: "Start coding and MILO will record your daily activity."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(summary.dailyRecords) { record in
                            WeeklyCodingSummaryDayCardView(record: record)
                        }
                    }
                }
            }

            MiloPanelCardView(title: "Source Control", subtitle: "Reset only local weekly aggregates when needed.") {
                HStack {
                    Text("MILO stores weekly coding summaries locally on this Mac.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Reset This Week", role: .destructive) {
                        weeklyService.resetWeeklyLocalStats()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
        } footer: {
            MiloPanelFooterView(
                message: "Weekly summary is privacy-friendly and local-first.",
                statusTitle: "Source: \(summary.sourceLabel)",
                statusTone: summary.sourceLabel.contains("WakaTime") ? .success : .neutral
            )
        }
        .onAppear { weeklyService.refreshWeeklySummary() }
    }

    private var weekRangeCard: some View {
        MiloPanelCardView(
            title: "Week Range",
            subtitle: "\(summary.weekStartDate.formatted(date: .abbreviated, time: .omitted)) \u{2013} \(summary.weekEndDate.formatted(date: .abbreviated, time: .omitted))",
            trailing: AnyView(
                MiloStatusPillView(title: summary.sourceLabel, systemImage: "lock.fill", tone: summary.sourceLabel.contains("WakaTime") ? .success : .neutral)
            )
        ) {
            if let productive = summary.mostProductiveDay, productive.codingSeconds > 0 {
                MiloStatusPillView(
                    title: "Most productive: \(productive.date.formatted(date: .abbreviated, time: .omitted)) \u{2022} \(formatSeconds(productive.codingSeconds))",
                    systemImage: "sparkles",
                    tone: .info
                )
            } else {
                MiloStatusPillView(title: "No active day yet", systemImage: "moon.zzz.fill", tone: .neutral)
            }
        }
    }

    private var heroCards: some View {
        LazyVGrid(columns: metricColumns, spacing: 16) {
            MiloMetricCardView(title: "Total Coding", value: formatSeconds(summary.totalCodingSeconds), systemImage: "clock")
            MiloMetricCardView(title: "Focus Time", value: formatSeconds(summary.totalCodingSeconds), systemImage: "eye")
            MiloMetricCardView(title: "Active Days", value: "\(summary.activeDays) / 7", systemImage: "calendar")
            if let best = summary.mostProductiveDay, best.codingSeconds > 0 {
                MiloMetricCardView(
                    title: "Best Day",
                    value: best.date.formatted(Date.FormatStyle().weekday(.abbreviated)) + " \u{2022} " + formatSeconds(best.codingSeconds),
                    systemImage: "sparkles"
                )
            } else {
                MiloMetricCardView(title: "Best Day", value: "-", systemImage: "sparkles")
            }
        }
    }

    private var dailyActivityCard: some View {
        MiloPanelCardView(title: "Daily Activity", subtitle: "Minutes coded per day this week.") {
            WeeklyActivityBarView(dailyRecords: summary.dailyRecords)
        }
    }

    private var languagesAndProjectsRow: some View {
        LazyVGrid(columns: dualColumns, spacing: 16) {
            MiloPanelCardView(title: "Top Languages", subtitle: summary.languageBreakdown.isEmpty ? "No language data yet." : "By coding time this week.") {
                CodingBreakdownListView(items: summary.languageBreakdown, color: .blue)
            }
            MiloPanelCardView(title: "Top Projects", subtitle: summary.projectBreakdown.isEmpty ? "No project data yet." : "By coding time this week.") {
                CodingBreakdownListView(items: summary.projectBreakdown, color: .orange)
            }
        }
    }

    private var focusPomodoroSection: some View {
        MiloPanelCardView(
            title: "Focus & Pomodoro",
            subtitle: "Your deep work stats for the week.",
            trailing: AnyView(
                MiloStatusPillView(title: "Local", systemImage: "lock.fill", tone: .neutral)
            )
        ) {
            LazyVGrid(columns: metricColumns, spacing: 12) {
                MiloMetricCardView(title: "Pomodoros", value: "\(summary.completedPomodoros)", systemImage: "timer")
                MiloMetricCardView(title: "Skipped Breaks", value: "\(summary.skippedBreaks)", systemImage: "figure.walk")
                MiloMetricCardView(title: "Todos Created", value: "\(summary.totalTodosCreated)", systemImage: "checklist")
                MiloMetricCardView(title: "Todos Completed", value: "\(summary.totalTodosCompleted)", systemImage: "checkmark.circle")
            }
        }
    }

    private var insightsCard: some View {
        MiloPanelCardView(title: "MILO Insights", subtitle: "Patterns and observations from your week.") {
            WeeklyInsightsView(insights: summary.insights)
        }
    }

    private var metricColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: 16)]
    }

    private var dualColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 260), spacing: 16)]
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

private struct WeeklyCodingSummaryDayCardView: View {
    let record: DailyCodingMetricsRecord

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.yellow.opacity(0.12))
                Image(systemName: "calendar.day.timeline.leading")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 8) {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        MiloStatusPillView(title: "\(record.sessionCount) sessions", systemImage: "timer", tone: .info)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                        MiloStatusPillView(title: "\(record.sessionCount) sessions", systemImage: "timer", tone: .info)
                    }
                }

                MiloAdaptiveActionRow(spacing: 8) {
                    MiloStatusPillView(title: formatSeconds(record.codingSeconds), systemImage: "clock", tone: record.codingSeconds > 0 ? .success : .neutral)
                    MiloStatusPillView(title: record.topLanguage ?? "No language", systemImage: "chevron.left.forwardslash.chevron.right", tone: .neutral)
                    MiloStatusPillView(title: "LOC \(record.locSummary.netLines)", systemImage: "plus.forwardslash.minus", tone: record.locSummary.netLines >= 0 ? .success : .warning)
                }
                Text([record.topProject, record.topEditor].compactMap { $0 }.joined(separator: " \u{2022} "))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.72))
        )
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}