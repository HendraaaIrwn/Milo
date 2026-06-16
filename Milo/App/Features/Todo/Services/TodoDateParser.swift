//
//  TodoDateParser.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct TodoDateParseResult: Equatable {
    let dueDate: Date?
    let remainingText: String
    let confidence: TodoParseConfidence
}

struct TodoDateParser {
    @MainActor
    static func extractDate(
        from input: String,
        now: Date,
        calendar: Calendar = .current
    ) -> TodoDateParseResult {
        let working = input.trimmingCharacters(in: .whitespacesAndNewlines)

        let handlers: [(String, Date, Calendar) -> TodoDateParseResult?] = [
            extractEnglishTomorrowAt,
            extractEnglishTodayAt,
            extractEnglishTonight,
            extractEnglishThisEvening,
            extractEnglishRelativeMinutes,
            extractEnglishRelativeHours,
            extractEnglishAtTime,
            extractEnglishTimeWithAmPm,

            extractIndonesianBesokJam,
            extractIndonesianHariIniJam,
            extractIndonesianNantiMalam,
            extractIndonesianSoreIni,
            extractIndonesianMalamIni,
            extractIndonesianDalamMenit,
            extractIndonesianDalamJam,
            extractIndonesianMenitLagi,
            extractIndonesianJamLagi,
            extractIndonesianJamWithModifier,
            extractIndonesianPukul,
            extractIndonesianJam,

            extractEnglishTomorrow,
            extractEnglishToday,
        ]

        // First pass: try specific handlers that modify the remaining text
        for handler in handlers {
            if let result = handler(working, now, calendar) {
                return result
            }
        }

        // No date found
        return TodoDateParseResult(
            dueDate: nil,
            remainingText: input,
            confidence: .high
        )
    }

    // MARK: - English Helpers

    private static func extractEnglishRelativeMinutes(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+in\s+(\d+)\s*(minutes|minute|mins|min|m)\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let numText = group(2, from: match, in: lower),
              let minutes = Int(numText)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = now.addingTimeInterval(TimeInterval(minutes * 60))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func extractEnglishRelativeHours(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+in\s+(\d+)\s*(hours|hour|hrs|hr|h)\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let numText = group(2, from: match, in: lower),
              let hours = Int(numText)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = now.addingTimeInterval(TimeInterval(hours * 3600))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func extractEnglishTomorrowAt(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        // tomorrow at 9, tomorrow 9am, tomorrow at 5pm, tomorrow 09:30
        let lower = input.lowercased()
        let patterns = [
            #"(.*?)\s+tomorrow\s+at\s+(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            #"(.*?)\s+tomorrow\s+at\s+(\d{1,2})\s*(am|pm)"#,
            #"(.*?)\s+tomorrow\s+(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            #"(.*?)\s+tomorrow\s+(\d{1,2})\s*(am|pm)"#,
            #"(.*?)\s+tomorrow\s+at\s+(\d{1,2})"#,
        ]

        return tryPatterns(patterns, in: lower, input: input, now: now, calendar: calendar, dayOffset: 1)
    }

    private static func extractEnglishTodayAt(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let patterns = [
            #"(.*?)\s+today\s+at\s+(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            #"(.*?)\s+today\s+(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            #"(.*?)\s+today\s+at\s+(\d{1,2})\s*(am|pm)"#,
            #"(.*?)\s+today\s+(\d{1,2})\s*(am|pm)"#,
        ]

        return tryPatterns(patterns, in: lower, input: input, now: now, calendar: calendar, dayOffset: 0)
    }

    private static func extractEnglishTomorrow(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+tomorrow\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = calendar.date(byAdding: .day, value: 1, to: makeDayStart(now, calendar: calendar))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractEnglishToday(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+today\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = makeDayStart(now, calendar: calendar)

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractEnglishTonight(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+tonight\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: 20, minute: 0, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractEnglishThisEvening(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+this\s+evening\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: 17, minute: 0, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractEnglishAtTime(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        // at 5pm, at 17:00
        let lower = input.lowercased()
        let patterns = [
            #"(.*?)\s+at\s+(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            #"(.*?)\s+at\s+(\d{1,2})\s*(am|pm)"#,
        ]

        for pattern in patterns {
            if let result = tryPatterns([pattern], in: lower, input: input, now: now, calendar: calendar, dayOffset: 0) {
                let adjusted = adjustIfPast(result.dueDate, now: now, calendar: calendar, dayOffset: 1)
                return TodoDateParseResult(dueDate: adjusted, remainingText: result.remainingText, confidence: result.confidence)
            }
        }
        return nil
    }

    private static func extractEnglishTimeWithAmPm(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+(\d{1,2})\s*(am|pm)\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let hourText = group(2, from: match, in: lower),
              var hour = Int(hourText),
              let ampm = group(3, from: match, in: lower)
        else { return nil }

        let minute = 0
        let after = group(4, from: match, in: input) ?? ""

        if ampm == "pm" && hour < 12 { hour += 12 }
        if ampm == "am" && hour == 12 { hour = 0 }

        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: hour, minute: minute, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .high)
    }

    // MARK: - Indonesian Helpers

    private static func extractIndonesianBesokJam(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        // besok jam 10, besok pukul 10, besok jam 09.30, besok pukul 09:30
        let patterns = [
            #"(.*?)\s+besok\s+(jam|pukul)\s+(\d{1,2})[\.:](\d{2})\s*(.*)"#,
            #"(.*?)\s+besok\s+(jam|pukul)\s+(\d{1,2})\s*(.*)"#,
            #"(.*?)\s+besok\s+(\d{1,2})[\.:](\d{2})\s*(.*)"#,
            #"(.*?)\s+besok\s+(\d{1,2})\s*(.*)"#,
        ]

        for pattern in patterns {
            if let result = tryIndonesianPatterns(pattern, input: input, lower: lower, now: now, calendar: calendar, dayOffset: 1) {
                return result
            }
        }
        return nil
    }

    private static func extractIndonesianHariIniJam(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let patterns = [
            #"(.*?)\s+(hari\s+ini)\s+(jam|pukul)\s+(\d{1,2})[\.:](\d{2})\s*(.*)"#,
            #"(.*?)\s+(hari\s+ini)\s+(jam|pukul)\s+(\d{1,2})\s*(.*)"#,
            #"(.*?)\s+(hari\s+ini)\s+(\d{1,2})[\.:](\d{2})\s*(.*)"#,
            #"(.*?)\s+(hari\s+ini)\s+(\d{1,2})\s*(.*)"#,
        ]

        for pattern in patterns {
            if let result = tryIndonesianPatternsV2(pattern, input: input, lower: lower, now: now, calendar: calendar, dayOffset: 0) {
                let adjusted = adjustIfPast(result.dueDate, now: now, calendar: calendar, dayOffset: 1)
                return TodoDateParseResult(dueDate: adjusted, remainingText: result.remainingText, confidence: result.confidence)
            }
        }
        return nil
    }

    private static func extractIndonesianNantiMalam(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+nanti\s+malam\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: 20, minute: 0, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractIndonesianSoreIni(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+sore\s+ini\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: 17, minute: 0, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractIndonesianMalamIni(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+malam\s+ini\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input)
        else { return nil }

        let after = group(2, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: 20, minute: 0, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .medium)
    }

    private static func extractIndonesianDalamMenit(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+dalam\s+(\d+)\s*(minutes|minute|mins|min|menit|m)\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let numText = group(2, from: match, in: lower),
              let minutes = Int(numText)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = now.addingTimeInterval(TimeInterval(minutes * 60))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func extractIndonesianDalamJam(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+dalam\s+(\d+)\s*(hours|hour|hrs|hr|jam|j|h)\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let numText = group(2, from: match, in: lower),
              let hours = Int(numText)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = now.addingTimeInterval(TimeInterval(hours * 3600))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func extractIndonesianMenitLagi(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+(\d+)\s+(minutes|minute|mins|min|menit|m)\s+lagi\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let numText = group(2, from: match, in: lower),
              let minutes = Int(numText)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = now.addingTimeInterval(TimeInterval(minutes * 60))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func extractIndonesianJamLagi(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let pattern = #"(.*?)\s+(\d+)\s+(hours|hour|hrs|hr|jam|j|h)\s+lagi\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let numText = group(2, from: match, in: lower),
              let hours = Int(numText)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""
        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = now.addingTimeInterval(TimeInterval(hours * 3600))

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func extractIndonesianJamWithModifier(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        // jam 5 sore, jam 5 pagi, jam 12 siang, jam 12 malam
        let pattern = #"(.*?)\s+jam\s+(\d{1,2})\s+(pagi|siang|sore|malam)\s*(.*)"#
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let hourText = group(2, from: match, in: lower),
              var hour = Int(hourText),
              let modifier = group(3, from: match, in: lower)
        else { return nil }

        let after = group(4, from: match, in: input) ?? ""

        switch modifier {
        case "pagi": if hour == 12 { hour = 0 }
        case "siang": if hour < 12 { hour = 12 }
        case "sore": if hour < 12 { hour += 12 }
        case "malam": if hour < 18 { hour = 20 }
        default: break
        }

        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = fixedTimeToday(hour: hour, minute: 0, now: now, calendar: calendar, defaultOffset: 0)
        let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

        return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .high)
    }

    private static func extractIndonesianPukul(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let patterns = [
            #"(.*?)\s+pukul\s+(\d{1,2})[\.:](\d{2})\s*(.*)"#,
            #"(.*?)\s+pukul\s+(\d{1,2})\s*(.*)"#,
        ]

        for pattern in patterns {
            guard let match = firstMatch(pattern: pattern, in: lower),
                  let before = group(1, from: match, in: input),
                  let hourText = group(2, from: match, in: lower),
                  let hour = Int(hourText)
            else { continue }

            let minute = Int(group(3, from: match, in: lower) ?? "0") ?? 0
            let after = group(4, from: match, in: input) ?? ""

            let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
            let dueDate = fixedTimeToday(hour: hour, minute: minute, now: now, calendar: calendar, defaultOffset: 0)
            let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

            return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .high)
        }
        return nil
    }

    private static func extractIndonesianJam(
        _ input: String, _ now: Date, _ calendar: Calendar
    ) -> TodoDateParseResult? {
        let lower = input.lowercased()
        let patterns = [
            #"(.*?)\s+jam\s+(\d{1,2})[\.:](\d{2})\s*(.*)"#,
            #"(.*?)\s+jam\s+(\d{1,2})\s*(.*)"#,
        ]

        for pattern in patterns {
            guard let match = firstMatch(pattern: pattern, in: lower),
                  let before = group(1, from: match, in: input),
                  let hourText = group(2, from: match, in: lower),
                  let hour = Int(hourText)
            else { continue }

            let minute = Int(group(3, from: match, in: lower) ?? "0") ?? 0
            let after = group(4, from: match, in: input) ?? ""

            let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)

            // jam 3 → 15:00 if 03:00 is past today
            let resolvedHour = (hour <= 12) ? adjustIndonesianHour(hour) : hour
            let dueDate = fixedTimeToday(hour: resolvedHour, minute: minute, now: now, calendar: calendar, defaultOffset: 0)
            let finalDate = adjustIfPast(dueDate, now: now, calendar: calendar, dayOffset: 1)

            return TodoDateParseResult(dueDate: finalDate, remainingText: remaining, confidence: .high)
        }
        return nil
    }

    // MARK: - Internal Helpers

    private static func tryPatterns(
        _ patterns: [String],
        in lower: String,
        input: String,
        now: Date,
        calendar: Calendar,
        dayOffset: Int
    ) -> TodoDateParseResult? {
        for pattern in patterns {
            guard let match = firstMatch(pattern: pattern, in: lower),
                  let before = group(1, from: match, in: input),
                  let hourText = group(2, from: match, in: lower),
                  var hour = Int(hourText)
            else { continue }

            let minute = Int(group(3, from: match, in: lower) ?? "0") ?? 0
            let ampm = group(4, from: match, in: lower)

            if let ampm {
                if ampm == "pm" && hour < 12 { hour += 12 }
                if ampm == "am" && hour == 12 { hour = 0 }
            }

            let after = group(5, from: match, in: input) ?? ""
            let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
            let dueDate = makeDate(dayOffset: dayOffset, hour: hour, minute: minute, now: now, calendar: calendar)

            return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
        }
        return nil
    }

    private static func tryIndonesianPatterns(
        _ pattern: String,
        input: String,
        lower: String,
        now: Date,
        calendar: Calendar,
        dayOffset: Int
    ) -> TodoDateParseResult? {
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let hourText = group(3, from: match, in: lower),
              let hour = Int(hourText)
        else { return nil }

        let minute = Int(group(4, from: match, in: lower) ?? "0") ?? 0
        let after = group(5, from: match, in: input) ?? ""

        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = makeDate(dayOffset: dayOffset, hour: hour, minute: minute, now: now, calendar: calendar)

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func tryIndonesianPatternsV2(
        _ pattern: String,
        input: String,
        lower: String,
        now: Date,
        calendar: Calendar,
        dayOffset: Int
    ) -> TodoDateParseResult? {
        guard let match = firstMatch(pattern: pattern, in: lower),
              let before = group(1, from: match, in: input),
              let hourText = group(4, from: match, in: lower),
              let hour = Int(hourText)
        else { return nil }

        let minute = Int(group(5, from: match, in: lower) ?? "0") ?? 0
        let after = group(6, from: match, in: input) ?? ""

        let remaining = (before + " " + after).trimmingCharacters(in: .whitespaces)
        let dueDate = makeDate(dayOffset: dayOffset, hour: hour, minute: minute, now: now, calendar: calendar)

        return TodoDateParseResult(dueDate: dueDate, remainingText: remaining, confidence: .high)
    }

    private static func adjustIndonesianHour(_ hour: Int) -> Int {
        if hour <= 6 { return hour } // early morning stays
        if hour <= 11 { return hour } // morning stays
        // jam 12 is siang
        return hour
    }

    private static func adjustIfPast(_ date: Date?, now: Date, calendar: Calendar, dayOffset: Int) -> Date? {
        guard let date else { return nil }
        if date <= now {
            return calendar.date(byAdding: .day, value: dayOffset, to: date)
        }
        return date
    }

    private static func fixedTimeToday(hour: Int, minute: Int, now: Date, calendar: Calendar, defaultOffset: Int) -> Date? {
        makeDate(dayOffset: 0, hour: hour, minute: minute, now: now, calendar: calendar)
    }

    private static func makeDayStart(_ now: Date, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 9
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? now
    }
}

// Regex helpers (shared between TodoDateParser and friends)
private func firstMatch(pattern: String, in text: String) -> NSTextCheckingResult? {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return regex.firstMatch(in: text, options: [], range: range)
}

private func group(_ index: Int, from match: NSTextCheckingResult, in text: String) -> String? {
    guard match.range(at: index).location != NSNotFound,
          let range = Range(match.range(at: index), in: text)
    else { return nil }
    return String(text[range])
}

private func makeDate(dayOffset: Int, hour: Int, minute: Int, now: Date, calendar: Calendar) -> Date? {
    guard hour >= 0, hour <= 23, minute >= 0, minute <= 59 else { return nil }
    guard let baseDay = calendar.date(byAdding: .day, value: dayOffset, to: now) else { return nil }
    var components = calendar.dateComponents([.year, .month, .day], from: baseDay)
    components.hour = hour
    components.minute = minute
    components.second = 0
    return calendar.date(from: components)
}

