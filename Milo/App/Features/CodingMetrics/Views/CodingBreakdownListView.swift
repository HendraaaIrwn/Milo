//
//  CodingBreakdownListView.swift
//  Milo
//

import SwiftUI

struct CodingBreakdownListView: View {
    let items: [CategoryBreakdown]
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            if items.isEmpty {
                Text("No data yet")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(items.prefix(5)) { item in
                    breakdownRow(item)
                }
            }
        }
    }

    private func breakdownRow(_ item: CategoryBreakdown) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(item.name)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                Spacer()
                Text("\(formatMinutes(item.minutes))")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", item.percentage))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, alignment: .trailing)
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

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 { return "\(minutes / 60)h \(minutes % 60)m" }
        return "\(minutes)m"
    }
}
