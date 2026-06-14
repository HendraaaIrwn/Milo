//
//  GitLOCTracker.swift
//  Milo
//
//  PRIVACY: MILO only runs `git diff --shortstat`, `git diff --name-only`, and `git log --numstat`.
//  Source code content is never read or stored. Only Git summary statistics are used.
//

import Foundation
import OSLog

struct GitLOCTracker {
    static let ignoredPathFragments = [
        "/node_modules/",
        "/.git/",
        "/build/",
        "/dist/",
        "/DerivedData/",
        "/vendor/",
        "/.next/",
        "/.nuxt/",
        "/.svelte-kit/",
        "/coverage/",
        "/Pods/",
        "/Carthage/",
        "/.swiftpm/"
    ]

    static let ignoredFilenameFragments = [
        ".generated.",
        ".min.js",
        ".min.css",
        ".pbxproj"
    ]

    private static nonisolated let logger = Logger(
        subsystem: "com.milo",
        category: "GitLOC"
    )

    static func workingTreeLOC(projectPath: String) async -> LOCSummary {
        let output = await runGit(
            arguments: ["diff", "--shortstat"],
            projectPath: projectPath
        )

        return parseShortstat(output)
    }

    static func changedFiles(projectPath: String) async -> [String] {
        let output = await runGit(
            arguments: ["diff", "--name-only"],
            projectPath: projectPath
        )

        return output
            .split(separator: "\n")
            .map(String.init)
            .filter { !shouldIgnore(path: $0) }
    }

    static func committedLOCToday(projectPath: String) async -> LOCSummary {
        let output = await runGit(
            arguments: [
                "log",
                "--since=midnight",
                "--numstat",
                "--pretty=format:"
            ],
            projectPath: projectPath
        )

        return parseNumstat(output)
    }

    static func totalLOCToday(projectPath: String) async -> LOCSummary {
        async let working = workingTreeLOC(projectPath: projectPath)
        async let committed = committedLOCToday(projectPath: projectPath)

        let (w, c) = await (working, committed)

        return LOCSummary(
            linesAdded: w.linesAdded + c.linesAdded,
            linesDeleted: w.linesDeleted + c.linesDeleted
        )
    }

    private static func runGit(
        arguments: [String],
        projectPath: String
    ) async -> String {
        await Task.detached(priority: .utility) {
            runGitSync(arguments: arguments, projectPath: projectPath)
        }.value
    }

    private static nonisolated func runGitSync(
        arguments: [String],
        projectPath: String
    ) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            logger.error("GitLOC: failed to run git: \(error.localizedDescription)")
            return ""
        }

        if process.terminationStatus != 0 {
            logger.debug("GitLOC: git \(arguments.joined(separator: " ")) exited with status \(process.terminationStatus) in \(projectPath)")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func parseShortstat(_ output: String) -> LOCSummary {
        var added = 0
        var deleted = 0

        let insertedPattern = #"(\d+)\s+insertion"#
        let deletedPattern = #"(\d+)\s+deletion"#

        if let inserted = firstNumber(pattern: insertedPattern, text: output) {
            added = inserted
        }

        if let removed = firstNumber(pattern: deletedPattern, text: output) {
            deleted = removed
        }

        return LOCSummary(
            linesAdded: added,
            linesDeleted: deleted
        )
    }

    private static func parseNumstat(_ output: String) -> LOCSummary {
        var added = 0
        var deleted = 0

        for line in output.split(separator: "\n").map(String.init) {
            let parts = line.split(separator: "\t").map(String.init)

            guard parts.count >= 3 else { continue }

            let filePath = parts[2]

            guard !shouldIgnore(path: filePath) else { continue }

            if let a = Int(parts[0]) {
                added += a
            }

            if let d = Int(parts[1]) {
                deleted += d
            }
        }

        return LOCSummary(
            linesAdded: added,
            linesDeleted: deleted
        )
    }

    private static func firstNumber(pattern: String, text: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)

        guard let match = regex.firstMatch(in: text, range: range),
              let numberRange = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return Int(text[numberRange])
    }

    static func shouldIgnore(path: String) -> Bool {
        let normalized = "/" + path

        if ignoredPathFragments.contains(where: { normalized.contains($0) }) {
            return true
        }

        if ignoredFilenameFragments.contains(where: { path.contains($0) }) {
            return true
        }

        return false
    }
}
