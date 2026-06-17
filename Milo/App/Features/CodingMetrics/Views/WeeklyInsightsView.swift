//
//  WeeklyInsightsView.swift
//  Milo
//

import SwiftUI

struct WeeklyInsightsView: View {
    let insights: [WeeklyInsight]

    var body: some View {
        VStack(spacing: 8) {
            if insights.isEmpty {
                Text("No insights yet. Start coding to generate weekly patterns.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(insights) { insight in
                    insightRow(insight)
                }
            }
        }
    }

    private func insightRow(_ insight: WeeklyInsight) -> some View {
        HStack(spacing: 10) {
            Image(systemName: insight.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(severityColor(insight.severity))
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text(insight.message)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
