//
//  WeeklyCodingSummaryCardView.swift
//  Milo
//

import SwiftUI

struct WeeklyCodingSummaryCardView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
        )
    }
}
