//
//  WeeklyCodingDayRowView.swift
//  Milo
//

import SwiftUI

struct WeeklyCodingDayRowView: View {
    private var metrics = MiloScaledMetrics()

    let record: DailyCodingMetricsRecord

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
        }
        .padding(.vertical, metrics.smallSpacing)
    }

    private var horizontalLayout: some View {
        HStack(alignment: .top, spacing: metrics.mediumSpacing) {
            dateBlock
                .frame(minWidth: 110, alignment: .leading)
            detailBlock
            Spacer(minLength: metrics.smallSpacing)
            locBlock
        }
    }

    private var verticalLayout: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            dateBlock
            detailBlock
            locBlock
        }
    }

    private var dateBlock: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(record.date.formatted(.dateTime.weekday(.wide)))
                .miloFont(.captionBold)
                .fixedSize(horizontal: false, vertical: true)

            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                .miloFont(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var detailBlock: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(formatSeconds(record.codingSeconds))
                .miloFont(.captionBold)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(record.topLanguage ?? "No language") • \(record.topProject ?? "No project")")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var locBlock: some View {
        HStack(spacing: metrics.smallSpacing) {
            Text("+\(record.locSummary.linesAdded)")
                .foregroundStyle(.green)

            Text("-\(record.locSummary.linesDeleted)")
                .foregroundStyle(.red)
        }
        .miloFont(.caption)
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