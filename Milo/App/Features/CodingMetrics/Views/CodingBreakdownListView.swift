//
//  CodingBreakdownListView.swift
//  Milo
//

import SwiftUI

struct CodingBreakdownListView: View {
    private var metrics = MiloScaledMetrics()

    let items: [CategoryBreakdown]
    let color: Color

    init(items: [CategoryBreakdown], color: Color) {
        self.items = items
        self.color = color
    }

    var body: some View {
        VStack(spacing: metrics.smallSpacing) {
            if items.isEmpty {
                Text("No data yet")
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, metrics.smallSpacing)
            } else {
                ForEach(items.prefix(5)) { item in
                    breakdownRow(item)
                }
            }
        }
    }

    private func breakdownRow(_ item: CategoryBreakdown) -> some View {
        VStack(spacing: metrics.tinySpacing) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: metrics.smallSpacing) {
                    rowTitle(item)
                    Spacer(minLength: metrics.smallSpacing)
                    rowValues(item)
                }

                VStack(alignment: .leading, spacing: metrics.tinySpacing) {
                    rowTitle(item)
                    rowValues(item)
                }
            }

            GeometryReader { geo in
                Capsule()
                    .fill(color.opacity(0.18))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.55))
                            .frame(width: max(4, geo.size.width * CGFloat(item.percentage / 100.0)))
                    }
            }
            .frame(height: 6)
        }
    }

    private func rowTitle(_ item: CategoryBreakdown) -> some View {
                Text(item.name)
            .miloFont(.caption, weight: .medium)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func rowValues(_ item: CategoryBreakdown) -> some View {
        HStack(spacing: metrics.smallSpacing) {
                Text("\(formatMinutes(item.minutes))")
                .miloFont(.captionBold)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", item.percentage))
                .miloFont(.caption2, weight: .medium)
                    .foregroundStyle(.secondary)
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 { return "\(minutes / 60)h \(minutes % 60)m" }
        return "\(minutes)m"
    }
}