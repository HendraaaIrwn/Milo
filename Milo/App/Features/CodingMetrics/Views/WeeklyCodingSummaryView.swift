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
            subtitle: "Review your focus time, projects, languages, and LOC this week.",
            systemImage: "calendar.badge.clock",
            primaryActionTitle: "Refresh",
            primaryActionSystemImage: "arrow.clockwise",
            primaryAction: {
                weeklyService.refreshWeeklySummary()
            }
        ) {
            MiloPanelCardView(
                title: "Week Range",
                subtitle: "\(summary.weekStartDate.formatted(date: .abbreviated, time: .omitted)) – \(summary.weekEndDate.formatted(date: .abbreviated, time: .omitted))",
                trailing: AnyView(
                    MiloStatusPillView(title: summary.sourceLabel, systemImage: "lock.fill", tone: summary.sourceLabel.contains("WakaTime") ? .success : .neutral)
                )
            ) {
                if let productive = summary.mostProductiveDay {
                    MiloStatusPillView(
                        title: "Most productive: \(productive.date.formatted(date: .abbreviated, time: .omitted)) • \(formatSeconds(productive.codingSeconds))",
                        systemImage: "sparkles",
                        tone: .info
                    )
                } else {
                    MiloStatusPillView(title: "No active day yet", systemImage: "moon.zzz.fill", tone: .neutral)
                }
            }

            MiloPanelCardView(
                title: "Weekly Metrics",
                subtitle: "Aggregated coding activity for this week."
            ) {
                LazyVGrid(columns: metricColumns, spacing: 16) {
                    MiloMetricCardView(title: "Total Coding Time", value: formatSeconds(summary.totalCodingSeconds), systemImage: "clock")
                    MiloMetricCardView(title: "Avg / Active Day", value: formatSeconds(summary.averageCodingSecondsPerActiveDay), systemImage: "chart.line.uptrend.xyaxis")
                    MiloMetricCardView(title: "Sessions", value: "\(summary.totalSessions)", systemImage: "timer")
                    MiloMetricCardView(title: "Top Language", value: summary.topLanguage ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                    MiloMetricCardView(title: "Top Project", value: summary.topProject ?? "-", systemImage: "folder")
                    MiloMetricCardView(title: "Top Editor", value: summary.topEditor ?? "-", systemImage: "macwindow")
                    MiloMetricCardView(title: "LOC Net", value: "\(summary.totalLOC.netLines)", systemImage: "plus.forwardslash.minus")
                    MiloMetricCardView(title: "Generated", value: summary.generatedAt.formatted(date: .omitted, time: .shortened), systemImage: "calendar")
                }
            }

            MiloPanelCardView(
                title: "Daily Breakdown",
                subtitle: "Card-like day rows with time, sessions, project, language, and LOC."
            ) {
                if summary.dailyRecords.isEmpty {
                    MiloEmptyStateView(
                        systemImage: "chart.bar.doc.horizontal",
                        title: "No coding metrics this week yet.",
                        message: "Start coding and MILO will build your weekly summary from local activity."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(summary.dailyRecords) { record in
                            WeeklyCodingSummaryDayCardView(record: record)
                        }
                    }
                }
            }

            MiloPanelCardView(
                title: "Source Control",
                subtitle: "Reset only local weekly aggregates when needed."
            ) {
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
        .onAppear {
            weeklyService.refreshWeeklySummary()
        }
    }

    private var metricColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

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
                HStack(alignment: .firstTextBaseline) {
                    Text(record.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 15, weight: .bold, design: .rounded))

                    Spacer()

                    MiloStatusPillView(title: "\(record.sessionCount) sessions", systemImage: "timer", tone: .info)
                }

                HStack(spacing: 8) {
                    MiloStatusPillView(title: formatSeconds(record.codingSeconds), systemImage: "clock", tone: record.codingSeconds > 0 ? .success : .neutral)
                    MiloStatusPillView(title: record.topLanguage ?? "No language", systemImage: "chevron.left.forwardslash.chevron.right", tone: .neutral)
                    MiloStatusPillView(title: "LOC \(record.locSummary.netLines)", systemImage: "plus.forwardslash.minus", tone: record.locSummary.netLines >= 0 ? .success : .warning)
                }

                Text([record.topProject, record.topEditor].compactMap { $0 }.joined(separator: " • "))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
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

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
}

//#Preview {
//    WeeklyCodingCardsView(week: .mock)
//}
