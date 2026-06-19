//
//  WeeklyActivityBarView.swift
//  Milo
//

import SwiftUI

struct WeeklyActivityBarView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var metrics = MiloScaledMetrics()

    let dailyRecords: [DailyCodingMetricsRecord]
    let calendar: Calendar

    init(dailyRecords: [DailyCodingMetricsRecord], calendar: Calendar = .current) {
        self.dailyRecords = dailyRecords
        self.calendar = calendar
    }

    var body: some View {
        let days = weekDays
        let maxMinutes = CGFloat(days.map(\.minutes).max() ?? 1)

        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                ForEach(days) { day in
                    HStack(alignment: .top, spacing: metrics.smallSpacing) {
                        Text(day.label)
                            .font(.caption.weight(.semibold))
                            .frame(minWidth: 42, alignment: .leading)

                        Text(formatLongMinutes(day.minutes))
                            .font(.caption)
                            .foregroundStyle(day.minutes > 0 ? Color.primary : Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, metrics.smallSpacing)
            .padding(.vertical, metrics.mediumSpacing)
        } else {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(days) { day in
                VStack(spacing: 6) {
                    Text(formatMinutes(day.minutes))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(day.minutes > 0 ? Color.primary : Color.secondary.opacity(0.4))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: day.minutes > 0
                                    ? [.green.opacity(0.7), .green.opacity(0.35)]
                                    : [.gray.opacity(0.2), .gray.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 28, height: barHeight(day.minutes, max: maxMinutes))

                    Text(day.label)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        }
    }

    private var weekDays: [DayBarItem] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        guard let monday = calendar.date(byAdding: .day, value: mondayOffset, to: today) else { return [] }

        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: monday) ?? today
            let record = dailyRecords.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
            let mins = (record?.codingSeconds ?? 0) / 60
            return DayBarItem(id: "day\(i)", label: labels[i], minutes: mins, date: date)
        }
    }

    private func barHeight(_ minutes: Int, max maxMinutes: CGFloat) -> CGFloat {
        guard maxMinutes > 0 else { return 6 }
        let ratio = CGFloat(minutes) / maxMinutes
        return Swift.max(6, ratio * 100)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 { return "\(minutes / 60)h" }
        if minutes > 0 { return "\(minutes)m" }
        return "-"
    }

    private func formatLongMinutes(_ minutes: Int) -> String {
        if minutes >= 60 { return "\(minutes / 60)h \(minutes % 60)m" }
        if minutes > 0 { return "\(minutes)m" }
        return "No coding time"
    }
}

private struct DayBarItem: Identifiable {
    let id: String
    let label: String
    let minutes: Int
    let date: Date
}
