//
//  NaturalLanguageReminderParser.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct ParsedReminderRequest: Equatable {
    let title: String
    let message: String
    let dueDate: Date
}

struct NaturalLanguageReminderParser {
    enum ParserError: Error, Equatable {
        case unsupportedFormat
        case invalidDate
        case missingMessage
    }

    static func parse(
        _ input: String,
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> ParsedReminderRequest {
        let original = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = original.normalizedReminderInput

        guard !original.isEmpty else { throw ParserError.missingMessage }

        if let parsed = try? parseRelative(original: original, normalized: normalized, now: now) {
            return parsed
        }

        if let parsed = try? parseAbsoluteTime(
            original: original,
            normalized: normalized,
            now: now,
            calendar: calendar
        ) {
            return parsed
        }

        throw ParserError.unsupportedFormat
    }

    private static func parseRelative(
        original: String,
        normalized: String,
        now: Date
    ) throws -> ParsedReminderRequest {
        let pattern = #"(?:\b(?:in|dalam)\s+)?(\d+)\s*(minutes|minute|mins|min|menit|hours|hour|hrs|hr|jam|j|m|h)\b"#

        guard let match = firstMatch(pattern: pattern, in: normalized),
              let numberText = group(1, from: match, in: normalized),
              let amount = Int(numberText),
              let unit = group(2, from: match, in: normalized)
        else { throw ParserError.unsupportedFormat }

        let seconds = isHourUnit(unit) ? 3_600 : 60
        let dueDate = now.addingTimeInterval(TimeInterval(amount * seconds))
        let message = cleanedMessage(
            original: original,
            normalized: normalized,
            removingRanges: [match.range],
            fallbackRange: messageRangeAroundRelative(match: match, in: normalized)
        )

        guard !message.isEmpty else { throw ParserError.missingMessage }
        return ParsedReminderRequest(title: message, message: message, dueDate: dueDate)
    }

    private static func parseAbsoluteTime(
        original: String,
        normalized: String,
        now: Date,
        calendar: Calendar
    ) throws -> ParsedReminderRequest {
        let dayOffset = detectedDayOffset(in: normalized)
        let timePattern = #"\b(?:at|jam|pukul)\s*(\d{1,2})(?:[:.]([0-5]\d))?\s*(am|pm|pagi|siang|sore|malam)?\b"#

        guard let match = firstMatch(pattern: timePattern, in: normalized),
              let hourText = group(1, from: match, in: normalized),
              let rawHour = Int(hourText)
        else { throw ParserError.unsupportedFormat }

        let minute = Int(group(2, from: match, in: normalized) ?? "0") ?? 0
        let meridiem = group(3, from: match, in: normalized)
        let hour = normalizedHour(rawHour, minute: minute, meridiem: meridiem, now: now, calendar: calendar)
        var offset = dayOffset ?? 0

        guard var dueDate = makeDate(dayOffset: offset, hour: hour, minute: minute, now: now, calendar: calendar) else {
            throw ParserError.invalidDate
        }

        if dayOffset == nil, dueDate <= now {
            offset = 1
            guard let tomorrow = makeDate(dayOffset: offset, hour: hour, minute: minute, now: now, calendar: calendar) else {
                throw ParserError.invalidDate
            }
            dueDate = tomorrow
        }

        let ranges = [match.range] + dayKeywordRanges(in: normalized)
        let message = cleanedMessage(
            original: original,
            normalized: normalized,
            removingRanges: ranges,
            fallbackRange: messageRangeAroundAbsolute(match: match, in: normalized)
        )

        guard !message.isEmpty else { throw ParserError.missingMessage }
        return ParsedReminderRequest(title: message, message: message, dueDate: dueDate)
    }

    private static func messageRangeAroundRelative(match: NSTextCheckingResult, in text: String) -> NSRange? {
        let afterText = substring(after: match.range, in: text)

        if let toMatch = firstMatch(pattern: #"\b(?:to|untuk|buat)\s+(.+)"#, in: afterText),
           let range = absoluteRange(of: toMatch.range(at: 1), in: afterText, offset: match.range.location + match.range.length) {
            return range
        }

        let beforeText = substring(before: match.range, in: text)
        if let beforeMatch = firstMatch(pattern: #"(?:remind me to|remind me|reminder to|ingatkan(?: aku| saya)?(?: untuk| buat)?|tolong ingatkan(?: aku| saya)?(?: untuk| buat)?)\s+(.+)"#, in: beforeText) {
            return beforeMatch.range(at: 1)
        }

        return nil
    }

    private static func messageRangeAroundAbsolute(match: NSTextCheckingResult, in text: String) -> NSRange? {
        let afterText = substring(after: match.range, in: text)

        if let afterMatch = firstMatch(pattern: #"(?:remind me to|remind me|ingatkan(?: aku| saya)?(?: untuk| buat)?|untuk|buat)?\s*(.+)"#, in: afterText),
           let range = absoluteRange(of: afterMatch.range(at: 1), in: afterText, offset: match.range.location + match.range.length),
           range.length > 0 {
            return range
        }

        let beforeText = substring(before: match.range, in: text)
        if let beforeMatch = firstMatch(pattern: #"(?:remind me to|remind me|ingatkan(?: aku| saya)?(?: untuk| buat)?|tolong ingatkan(?: aku| saya)?(?: untuk| buat)?)\s+(.+)"#, in: beforeText) {
            return beforeMatch.range(at: 1)
        }

        return nil
    }

    private static func cleanedMessage(
        original: String,
        normalized: String,
        removingRanges: [NSRange],
        fallbackRange: NSRange?
    ) -> String {
        if let fallbackRange,
           let range = Range(fallbackRange, in: original) {
            let direct = String(original[range]).cleanedReminderMessage
            if !direct.isEmpty { return direct }
        }

        var removable = removingRanges.compactMap { Range($0, in: original) }
        removable.sort { $0.lowerBound > $1.lowerBound }

        var message = original
        for range in removable {
            message.removeSubrange(range)
        }

        return message
            .replacingOccurrences(
                of: #"\b(remind me to|remind me|reminder to|set reminder to|set a reminder to|ingatkan aku untuk|ingatkan saya untuk|ingatkan aku|ingatkan saya|tolong ingatkan aku untuk|tolong ingatkan saya untuk|tolong ingatkan aku|tolong ingatkan saya|hari ini|besok|today|tomorrow|untuk|buat)\b"#,
                with: " ",
                options: [.regularExpression, .caseInsensitive]
            )
            .cleanedReminderMessage
    }

    private static func detectedDayOffset(in text: String) -> Int? {
        if firstMatch(pattern: #"\b(tomorrow|besok)\b"#, in: text) != nil { return 1 }
        if firstMatch(pattern: #"\b(today|hari ini)\b"#, in: text) != nil { return 0 }
        return nil
    }

    private static func dayKeywordRanges(in text: String) -> [NSRange] {
        allMatches(pattern: #"\b(tomorrow|besok|today|hari ini)\b"#, in: text).map(\.range)
    }

    private static func normalizedHour(
        _ hour: Int,
        minute: Int,
        meridiem: String?,
        now: Date,
        calendar: Calendar
    ) -> Int {
        let lowerMeridiem = meridiem?.lowercased()

        switch lowerMeridiem {
        case "pm", "sore", "malam":
            return hour < 12 ? hour + 12 : hour
        case "am", "pagi":
            return hour == 12 ? 0 : hour
        case "siang":
            return hour < 11 ? hour + 12 : hour
        default:
            guard (1...11).contains(hour),
                  let morning = makeDate(dayOffset: 0, hour: hour, minute: minute, now: now, calendar: calendar),
                  morning <= now
            else { return hour }

            return hour + 12
        }
    }

    private static func isHourUnit(_ unit: String) -> Bool {
        ["j", "jam", "h", "hr", "hrs", "hour", "hours"].contains(unit.lowercased())
    }

    private static func firstMatch(pattern: String, in text: String) -> NSTextCheckingResult? {
        allMatches(pattern: pattern, in: text).first
    }

    private static func allMatches(pattern: String, in text: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, options: [], range: range)
    }

    private static func group(_ index: Int, from match: NSTextCheckingResult, in text: String) -> String? {
        guard match.numberOfRanges > index,
              let range = Range(match.range(at: index), in: text)
        else { return nil }

        return String(text[range])
    }

    private static func makeDate(
        dayOffset: Int,
        hour: Int,
        minute: Int,
        now: Date,
        calendar: Calendar
    ) -> Date? {
        guard (0...23).contains(hour), (0...59).contains(minute),
              let baseDay = calendar.date(byAdding: .day, value: dayOffset, to: now)
        else { return nil }

        var components = calendar.dateComponents([.year, .month, .day], from: baseDay)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)
    }

    private static func substring(after range: NSRange, in text: String) -> String {
        let start = min(range.location + range.length, (text as NSString).length)
        return (text as NSString).substring(from: start)
    }

    private static func substring(before range: NSRange, in text: String) -> String {
        (text as NSString).substring(to: max(0, range.location))
    }

    private static func absoluteRange(of range: NSRange, in _: String, offset: Int) -> NSRange? {
        guard range.location != NSNotFound else { return nil }
        return NSRange(location: offset + range.location, length: range.length)
    }
}

private extension String {
    var normalizedReminderInput: String {
        lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var cleanedReminderMessage: String {
        replacingOccurrences(of: #"^[\s,.:;-]+|[\s,.:;-]+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
