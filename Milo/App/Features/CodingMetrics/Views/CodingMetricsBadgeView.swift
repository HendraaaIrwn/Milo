//
//  CodingMetricsBadgeView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsBadgeView: View {
    @ObservedObject var service: CodingMetricsService

    private var snapshot: CodingMetricsSnapshot {
        service.snapshot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundStyle(.primary)
                    .font(.system(size: 10, weight: .bold))

                Text(formatSeconds(snapshot.codingSecondsToday))
                    .foregroundStyle(.primary)
                    .font(.system(size : 11, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.primary)

            HStack(spacing: 6) {
                Text(snapshot.topLanguage ?? "No language")
                    .foregroundStyle(Color.blue)
                Text("+\(snapshot.locToday.linesAdded)")
                    .foregroundStyle(Color.green)
                Text("-\(snapshot.locToday.linesDeleted)")
                    .foregroundStyle(Color.red)
            }
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
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
