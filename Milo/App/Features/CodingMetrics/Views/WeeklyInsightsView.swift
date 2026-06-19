//
//  WeeklyInsightsView.swift
//  Milo
//

import SwiftUI

struct WeeklyInsightsView: View {
    private var metrics = MiloScaledMetrics()

    let insights: [WeeklyInsight]

    init(insights: [WeeklyInsight]) {
        self.insights = insights
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            if insights.isEmpty {
                Text("No insights yet. Start coding to generate weekly patterns.")
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, metrics.smallSpacing)
            } else {
                ForEach(insights) { insight in
                    insightRow(insight)
                }
            }
        }
    }

    private func insightRow(_ insight: WeeklyInsight) -> some View {
        HStack(alignment: .top, spacing: metrics.smallSpacing) {
            Image(systemName: insight.icon)
                .miloFont(.body, weight: .semibold)
                .foregroundStyle(severityColor(insight.severity))
                .frame(width: metrics.iconSize)

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .miloFont(.captionBold)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text(insight.message)
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(severityColor(insight.severity).opacity(0.08))
        )
    }

    private func severityColor(_ severity: InsightSeverity) -> Color {
        switch severity {
        case .positive: return .green
        case .neutral:  return .blue
        case .warning:  return .orange
        }
    }
}