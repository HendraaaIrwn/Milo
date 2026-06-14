import Foundation

struct PomodoroStats: Codable, Equatable {
    var dateKey: String
    var pomodorosToday: Int
    var totalFocusSecondsToday: Int
    var streakDays: Int
    var skippedBreaksToday: Int
    var lastCompletedFocusDate: Date?

    static func empty(for date: Date = Date()) -> PomodoroStats {
        PomodoroStats(
            dateKey: makeDateKey(date),
            pomodorosToday: 0,
            totalFocusSecondsToday: 0,
            streakDays: 0,
            skippedBreaksToday: 0,
            lastCompletedFocusDate: nil
        )
    }

    static func makeDateKey(_ date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}
