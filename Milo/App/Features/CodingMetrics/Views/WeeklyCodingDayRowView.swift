//
//  WeeklyCodingDayRowView.swift
//  Milo
//

import SwiftUI

struct WeeklyCodingDayRowView: View {
    let record: DailyCodingMetricsRecord

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(record.date.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 110, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(formatSeconds(record.codingSeconds))
                    .font(.system(size: 13, weight: .bold, design: .rounded))

                HStack(spacing: 6) {
                    Text(record.topLanguage ?? "No language")
                    Text("•")
                    Text(record.topProject ?? "No project")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("+\(record.locSummary.linesAdded)")
                    .foregroundStyle(.green)

                Text("-\(record.locSummary.linesDeleted)")
                    .foregroundStyle(.red)
            }
            .font(.caption)
        }
        .padding(.vertical, 6)
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
