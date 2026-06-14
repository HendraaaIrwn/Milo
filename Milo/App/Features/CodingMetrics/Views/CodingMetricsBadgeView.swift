//
//  CodingMetricsBadgeView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsBadgeView: View {
    @ObservedObject var coordinator: CodingMetricsCoordinator

    private var snapshot: CodingMetricsSnapshot {
        coordinator.localMetricsService.snapshot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 10, weight: .bold))

                Text(formatSeconds(snapshot.codingSecondsToday))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }

            HStack(spacing: 6) {
                Text(snapshot.topLanguage ?? "No language")
                Text("+\(snapshot.locToday.linesAdded)")
                Text("-\(snapshot.locToday.linesDeleted)")
            }
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.92))
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
