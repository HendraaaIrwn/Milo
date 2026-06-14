//
//  LanguageEstimator.swift
//  Milo
//
//  PRIVACY: Language is estimated from file extension only. Source code content is never read.
//

import Foundation

struct LanguageEstimator {
    private static let extensionMap: [String: String] = [
        "swift": "Swift",
        "js": "JavaScript",
        "jsx": "JavaScript",
        "ts": "TypeScript",
        "tsx": "TypeScript",
        "py": "Python",
        "java": "Java",
        "kt": "Kotlin",
        "kts": "Kotlin",
        "go": "Go",
        "rs": "Rust",
        "c": "C",
        "h": "C/C++",
        "cpp": "C++",
        "hpp": "C++",
        "cs": "C#",
        "php": "PHP",
        "rb": "Ruby",
        "erb": "Ruby",
        "dart": "Dart",
        "html": "HTML",
        "htm": "HTML",
        "css": "CSS",
        "scss": "SCSS",
        "sass": "SCSS",
        "less": "CSS",
        "json": "JSON",
        "md": "Markdown",
        "sql": "SQL",
        "sh": "Shell",
        "bash": "Shell",
        "zsh": "Shell",
        "yml": "YAML",
        "yaml": "YAML",
        "xml": "XML",
        "vue": "Vue",
        "svelte": "Svelte"
    ]

    static func estimateLanguage(forFilePath path: String) -> String? {
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
        return extensionMap[ext]
    }

    static func estimateTopLanguage(fromChangedFiles files: [String]) -> String? {
        let languages = files.compactMap { estimateLanguage(forFilePath: $0) }

        let counts = Dictionary(grouping: languages, by: { $0 })
            .mapValues { $0.count }

        return counts.max(by: { $0.value < $1.value })?.key
    }
}
