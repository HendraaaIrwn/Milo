//
//  MiloAIResponseSafetyFilter.swift
//  Milo
//

import Foundation

struct MiloAIResponseSafetyFilter {
    func sanitize(_ response: String, maxWords: Int) -> String? {
        var text = response
            .trimmingCharacters(in: .whitespacesAndNewlines)

        text = text.replacingOccurrences(of: "\"", with: "")
        text = text.replacingOccurrences(of: "\n", with: " ")

        while text.contains("  ") {
            text = text.replacingOccurrences(of: "  ", with: " ")
        }

        guard !text.isEmpty else { return nil }

        let forbiddenFragments = [
            "as an ai",
            "i am an ai",
            "language model",
            "source code says",
            "clipboard",
            "password",
            "api key",
            "secret key",
            "private file",
            "system prompt"
        ]

        let lowercased = text.lowercased()
        for fragment in forbiddenFragments {
            if lowercased.contains(fragment) { return nil }
        }

        let words = text.split(separator: " ")
        if words.count > maxWords {
            text = words.prefix(maxWords).joined(separator: " ")
        }

        return text
    }
}
