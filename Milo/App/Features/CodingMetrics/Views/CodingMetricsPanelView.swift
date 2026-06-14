//
//  CodingMetricsPanelView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsPanelView: View {
    @ObservedObject var coordinator: CodingMetricsCoordinator

    private var snapshot: CodingMetricsSnapshot {
        coordinator.localMetricsService.snapshot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Coding Metrics")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Spacer()

                Text(coordinator.sourceLabel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.12))
                    .clipShape(Capsule())
            }

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    metricCard("Coding Today", formatSeconds(snapshot.codingSecondsToday))
                    metricCard("Session", formatSeconds(snapshot.currentSessionSeconds))
                }

                GridRow {
                    metricCard("Top Language", snapshot.topLanguage ?? "-")
                    metricCard("Top Project", snapshot.topProject ?? "-")
                }

                GridRow {
                    metricCard("Top Editor", snapshot.topEditor ?? "-")
                    metricCard("LOC", "+\(snapshot.locToday.linesAdded) / -\(snapshot.locToday.linesDeleted)")
                }
            }

            Divider()

            LOCSummaryView(loc: snapshot.locToday)

            Divider()

            Button("Refresh WakaTime") {
                coordinator.refreshWakaTime()
            }

            Button("Reset Local Stats", role: .destructive) {
                coordinator.localMetricsService.resetLocalStats()
            }

            Spacer()
        }
        .padding(18)
        .frame(width: 520, height: 480)
    }

    private func metricCard(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.9))
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
