//
//  WeeklyCodingSummaryCardView.swift
//  Milo
//

import SwiftUI

struct WeeklyCodingSummaryCardView: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.body.weight(.bold))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(metrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
        )
    }
}
