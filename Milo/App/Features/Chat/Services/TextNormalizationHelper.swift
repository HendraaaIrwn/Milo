//
//  TextNormalizationHelper.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

struct TextNormalizationHelper {
    static func normalize(_ input: String) -> String {
        input
            .lowercased()
            .replacingOccurrences(of: "：", with: ":")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "\\.", with: ".", options: .regularExpression)
        // Collapse whitespace
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    static func stripPunctuation(_ input: String) -> String {
        input
            .replacingOccurrences(of: "[.,!?;:]+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func removePrefix(_ input: String, prefixes: [String]) -> String {
        var result = input
        for prefix in prefixes {
            if result.hasPrefix(prefix) {
                result = String(result.dropFirst(prefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        return result
    }
}
