//
//  TodoCommandParser.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

// MARK: - Result Types

struct ParsedTodoCommand: Equatable {
    let title: String
    let notes: String?
    let dueDate: Date?
    let shouldCreateReminder: Bool
    let priority: TodoPriority
    let sourceLanguage: TodoCommandLanguage
    let confidence: TodoParseConfidence
    let originalInput: String
}

enum TodoCommandLanguage: String, Codable, Equatable {
    case english
    case indonesian
    case mixed
    case unknown
}

enum TodoParseConfidence: String, Codable, Equatable {
    case high
    case medium
    case low
}

enum TodoCommandParserError: Error, Equatable {
    case unsupportedFormat
    case missingTitle
    case invalidDate
    case ambiguousDate
}

// MARK: - Main Parser

struct TodoCommandParser {
    static func parse(
        _ input: String,
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> ParsedTodoCommand {
        let originalInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !originalInput.isEmpty else { throw TodoCommandParserError.missingTitle }

        let normalized = TextNormalizationHelper.normalize(originalInput)
        guard looksLikeTodoCommand(normalized) else {
            throw TodoCommandParserError.unsupportedFormat
        }

        let language = detectLanguage(normalized)
        let shouldCreateReminder = detectReminderIntent(normalized)

        let notesResult = extractNotes(from: originalInput)
        let priority = extractPriority(from: notesResult.mainText)

        let dateResult = TodoDateParser.extractDate(
            from: notesResult.mainText,
            now: now,
            calendar: calendar
        )

        let title = cleanTitle(
            from: dateResult.remainingText,
            normalizedLower: normalized,
            shouldCreateReminder: shouldCreateReminder
        )

        guard !title.isEmpty else { throw TodoCommandParserError.missingTitle }

        let confidence: TodoParseConfidence = dateResult.dueDate != nil ? .high : .medium

        return ParsedTodoCommand(
            title: title,
            notes: notesResult.notes,
            dueDate: dateResult.dueDate,
            shouldCreateReminder: shouldCreateReminder,
            priority: priority,
            sourceLanguage: language,
            confidence: confidence,
            originalInput: originalInput
        )
    }

    // MARK: - Intent Detection

    private static func looksLikeTodoCommand(_ normalized: String) -> Bool {
        for keyword in todoKeywords {
            if normalized.hasPrefix(keyword) {
                return true
            }
        }
        return false
    }

    private static let todoKeywords: [String] = [
        "add todo:",
        "add todo ",
        "add todo",
        "todo:",
        "todo ",
        "todo",
        "new todo:",
        "new todo ",
        "new todo",
        "create todo:",
        "create todo ",
        "create todo",
        "task:",
        "task ",
        "add task:",
        "add task ",

        "buat todo:",
        "buat todo ",
        "buat todo",
        "tambah todo:",
        "tambah todo ",
        "tambah todo",
        "catat todo:",
        "catat todo ",
        "catat todo",
        "tugas:",
        "tugas ",
        "buat tugas:",
        "buat tugas ",
        "tambah tugas:",
        "tambah tugas ",

        "remind todo",
        "todo reminder",
        "remind me to todo",
        "ingatkan todo",
        "ingatkan aku untuk todo",
        "buat todo reminder",
    ]

    private static let reminderKeywords: Set<String> = [
        "remind todo",
        "todo reminder",
        "remind me to todo",
        "ingatkan todo",
        "ingatkan aku untuk todo",
        "buat todo reminder",
    ]

    private static func detectReminderIntent(_ normalized: String) -> Bool {
        for keyword in reminderKeywords {
            if normalized.hasPrefix(keyword) {
                return true
            }
        }
        return false
    }

    private static func detectLanguage(_ normalized: String) -> TodoCommandLanguage {
        let englishPrefixes: Set<String> = ["add todo", "todo", "new todo", "create todo", "task", "add task", "remind todo", "todo reminder", "remind me to todo"]
        let indonesianPrefixes: Set<String> = ["buat todo", "tambah todo", "catat todo", "tugas", "buat tugas", "tambah tugas", "ingatkan todo", "ingatkan aku untuk todo", "buat todo reminder"]

        let hasEnglish = englishPrefixes.contains { normalized.hasPrefix($0) }
        let hasIndonesian = indonesianPrefixes.contains { normalized.hasPrefix($0) }

        if hasEnglish && hasIndonesian { return .mixed }
        if hasEnglish { return .english }
        if hasIndonesian { return .indonesian }

        // Check content for language hints
        let idMarkers: Set<String> = ["besok", "hari ini", "jam", "pukul", "menit", "nanti", "malam", "sore", "pagi", "siang", "dalam", "lagi"]
        let enMarkers: Set<String> = ["tomorrow", "today", "tonight", "evening", "minute", "minutes", "hour", "hours", "am", "pm"]

        let idCount = idMarkers.filter { normalized.contains($0) }.count
        let enCount = enMarkers.filter { normalized.contains($0) }.count

        if idCount > enCount { return .indonesian }
        if enCount > idCount { return .english }

        return .unknown
    }

    // MARK: - Notes Extraction

    private struct NotesExtractionResult {
        let mainText: String
        let notes: String?
    }

    private static func extractNotes(from input: String) -> NotesExtractionResult {
        // Format: title | notes: ... or title || notes: ... or title --note ...
        let normalized = input.lowercased()

        // Check for "| notes:" or "|| notes:"
        let notePatterns: [String] = [
            #"\s*\|\s*notes?:\s*(.+)"#,
            #"\s*\|\s*catatan?:\s*(.+)"#,
            #"\s*\|\s*note:\s*(.+)"#,
            #"\s*--notes?\s+(.+)"#,
            #"\s*--catatan\s+(.+)"#,
        ]

        for pattern in notePatterns {
            if let match = firstMatch(pattern: pattern, in: normalized),
               let noteText = group(1, from: match, in: input) {
                let mainText = input.replacingOccurrences(of: input[Range(match.range(at: 0), in: input)!], with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return NotesExtractionResult(mainText: mainText, notes: noteText.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        return NotesExtractionResult(mainText: input, notes: nil)
    }

    // MARK: - Priority Extraction

    private static let priorityPatterns: [(pattern: String, priority: TodoPriority)] = [
        ( #"\bhigh\b"#, .high ),
        ( #"\burgent\b"#, .high ),
        ( #"\bpenting\b"#, .high ),
        ( #"\bprioritas\s+tinggi\b"#, .high ),
        ( #"\bmendesak\b"#, .high ),
        ( #"\bnormal\b"#, .normal ),
        ( #"\bbiasa\b"#, .normal ),
        ( #"\blow\b"#, .low ),
        ( #"\brendah\b"#, .low ),
        ( #"\bsantai\b"#, .low ),
        ( #"\bprioritas\s+rendah\b"#, .low ),
    ]

    private static func extractPriority(from input: String) -> TodoPriority {
        // Check prefix patterns: "add todo high:", "add todo high:", "high:"
        let lower = input.lowercased()

        // Pattern: "add todo high: title" or "todo high: title"
        let prefixPriorityPattern = #"^(add todo|todo|buat todo|tambah todo|new todo|create todo)\s+(high|urgent|penting|low|rendah|santai|normal|biasa|mendesak|prioritas\s+tinggi|prioritas\s+rendah)\s*:"#
        if let match = firstMatch(pattern: prefixPriorityPattern, in: lower) {
            let priorityText = group(2, from: match, in: lower) ?? ""
            return mapPriorityText(priorityText)
        }

        // Pattern: "add todo high: title" (without colon after high)
        let prefixPriorityPattern2 = #"^(add todo|todo|buat todo|tambah todo|new todo|create todo)\s+(high|urgent|penting|low|rendah|santai|normal|biasa|mendesak)\s"#
        if let match = firstMatch(pattern: prefixPriorityPattern2, in: lower) {
            let priorityText = group(2, from: match, in: lower) ?? ""
            return mapPriorityText(priorityText)
        }

        // Check suffix: "priority high", "priority low"
        if lower.contains("priority high") || lower.contains("high priority") { return .high }
        if lower.contains("priority low") || lower.contains("low priority") { return .low }
        if lower.contains("priority normal") || lower.contains("normal priority") { return .normal }

        return .normal
    }

    private static func mapPriorityText(_ text: String) -> TodoPriority {
        switch text {
        case "high", "urgent", "penting", "mendesak", "prioritas tinggi":
            return .high
        case "low", "rendah", "santai", "prioritas rendah":
            return .low
        case "normal", "biasa":
            return .normal
        default:
            return .normal
        }
    }

    // MARK: - Clean Title

    private static func cleanTitle(from text: String, normalizedLower: String, shouldCreateReminder: Bool) -> String {
        var result = text

        // Remove command prefixes
        let sortedPrefixes = todoKeywords.sorted { $0.count > $1.count }
        for prefix in sortedPrefixes {
            if result.lowercased().hasPrefix(prefix) {
                result = String(result.dropFirst(prefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }

        // Remove reminder prefix words that might remain
        if shouldCreateReminder {
            let reminderRemove: [String] = [
                "remind todo", "remind me to todo", "todo reminder",
                "ingatkan todo", "ingatkan aku untuk todo", "buat todo reminder",
                "remind me to", "remind todo:",
            ]
            for prefix in reminderRemove {
                if result.lowercased().hasPrefix(prefix) {
                    result = String(result.dropFirst(prefix.count))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    break
                }
            }
        }

        // Remove priority keywords from title (if they were inline)
        let priorityRemove: [String] = [
            "high priority", "low priority", "normal priority",
            "priority high", "priority low", "priority normal",
        ]
        for p in priorityRemove {
            if result.lowercased().hasSuffix(p) {
                result = String(result.dropLast(p.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        // Remove trailing punctuation
        while result.hasSuffix(".") || result.hasSuffix(",") || result.hasSuffix(":") || result.hasSuffix(";") {
            result = String(result.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Remove leading punctuation (e.g. ": fix login bug" after stripping "add todo :")
        while result.hasPrefix(":") || result.hasPrefix(";") || result.hasPrefix(".") || result.hasPrefix(",") {
            result = String(result.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return result
    }
}

// MARK: - Regex Helpers (fileprivate to avoid conflict with TodoDateParser)

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
