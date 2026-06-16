//
//  CodingMetricsPanelView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsPanelView: View {
    @ObservedObject var coordinator: CodingMetricsCoordinator
    @ObservedObject var service: CodingMetricsService

    var onOpenWeeklySummary: () -> Void = {}
    var onOpenFileWatcherSettings: () -> Void = {}

    private var snapshot: CodingMetricsSnapshot {
        service.snapshot
    }

    private var hasWakaTime: Bool {
        coordinator.wakaTimeSummary != nil
    }

    private var isTracking: Bool {
        snapshot.currentSessionSeconds > 0
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Coding Metrics",
            subtitle: "Track local coding activity, editor usage, project time, and LOC.",
            systemImage: "chart.bar.xaxis",
            primaryActionTitle: "Weekly Summary",
            primaryActionSystemImage: "calendar.badge.clock",
            primaryAction: onOpenWeeklySummary
        ) {
            MiloPanelCardView(
                title: "Today Overview",
                subtitle: "Your active coding snapshot for today.",
                trailing: AnyView(
                    MiloStatusPillView(
                        title: hasWakaTime ? "Local + WakaTime" : "Local",
                        systemImage: "circle.fill",
                        tone: hasWakaTime ? .success : .neutral
                    )
                )
            ) {
                LazyVGrid(columns: metricColumns, spacing: 16) {
                    MiloMetricCardView(title: "Coding Today", value: formatSeconds(snapshot.codingSecondsToday), systemImage: "clock")
                    MiloMetricCardView(title: "Session", value: formatSeconds(snapshot.currentSessionSeconds), systemImage: "timer")
                    MiloMetricCardView(title: "Top Editor", value: snapshot.topEditor ?? "-", systemImage: "macwindow")
                    MiloMetricCardView(title: "Top Project", value: snapshot.topProject ?? "-", systemImage: "folder")
                    MiloMetricCardView(title: "Top Language", value: snapshot.topLanguage ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                    MiloMetricCardView(title: "LOC Net", value: "\(snapshot.locToday.netLines)", systemImage: "plus.forwardslash.minus")
                }
            }

            MiloPanelCardView(
                title: "Lines of Code",
                subtitle: "Git-based added, deleted, and net line changes."
            ) {
                HStack(spacing: 14) {
                    MiloStatusPillView(title: "+\(snapshot.locToday.linesAdded)", systemImage: "plus.circle.fill", tone: .success)
                    MiloStatusPillView(title: "-\(snapshot.locToday.linesDeleted)", systemImage: "minus.circle.fill", tone: .danger)
                    MiloStatusPillView(title: "Net \(snapshot.locToday.netLines)", systemImage: "equal.circle.fill", tone: .info)
                }
            }

            MiloPanelCardView(
                title: "WakaTime",
                subtitle: "Optional external enrichment. Local metrics still work without it.",
                trailing: AnyView(
                    MiloStatusPillView(
                        title: hasWakaTime ? "Connected" : "Not Connected",
                        systemImage: "circle.fill",
                        tone: hasWakaTime ? .success : .warning
                    )
                )
            ) {
                if let waka = coordinator.wakaTimeSummary {
                    LazyVGrid(columns: metricColumnsWaka, spacing: 16) {
                        MiloMetricCardView(title: "Time", value: formatSeconds(waka.totalSeconds), systemImage: "clock.badge.checkmark")
                        MiloMetricCardView(title: "Top Language", value: waka.topLanguage ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                        MiloMetricCardView(title: "Top Project", value: waka.topProject ?? "-", systemImage: "folder.fill")
                        MiloMetricCardView(title: "Top Editor", value: topEditor(from: waka.editorUsage) ?? "-", systemImage: "macwindow")
                    }
                } else {
                    MiloEmptyStateView(
                        systemImage: "bolt.horizontal.circle",
                        title: "WakaTime not connected",
                        message: "Connect WakaTime from settings when you want external coding summaries. MILO keeps local metrics working without it.",
                        buttonTitle: "Refresh WakaTime",
                        buttonSystemImage: "arrow.clockwise",
                        action: coordinator.refreshWakaTime
                    )
                }
            }

            MiloPanelCardView(
                title: "Quick Actions",
                subtitle: "Manage local metrics and project activity."
            ) {
                HStack(spacing: 12) {
                    Button("Refresh WakaTime") {
                        coordinator.refreshWakaTime()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    

                    Button("File Watcher") {
                        onOpenFileWatcherSettings()
                    }

                    Spacer()

                    Button("Reset Local Stats", role: .destructive) {
                        coordinator.localMetricsService.resetLocalStats()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
        } footer: {
            MiloPanelFooterView(
                message: "Local coding metrics stay on your Mac.",
                statusTitle: isTracking ? "Tracking" : coordinator.sourceLabel,
                statusTone: isTracking ? .success : .neutral
            )
        }
    }

    private var metricColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
    
    private var metricColumnsWaka: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
    }

    private func topEditor(from usage: [String: Int]) -> String? {
        usage.max(by: { $0.value < $1.value })?.key
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
