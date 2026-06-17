//
//  GitLOCTracker.swift
//  Milo
//
//  PRIVACY: MILO only runs `git diff --numstat`, `git diff --name-only`, `git log --numstat`,
//  and `git rev-parse --show-toplevel`. Source code content is never read or stored.
//

import Foundation
import OSLog

final class GitLOCTracker {
    private let bookmarkStore: SecurityScopedBookmarkStore

    private let logger = Logger(
        subsystem: "com.milo",
        category: "GitLOC"
    )

    init(bookmarkStore: SecurityScopedBookmarkStore = .shared) {
        self.bookmarkStore = bookmarkStore
    }

    func canAccess(_ project: WatchedProject) -> Bool {
        let result = accessProjectURL(project)
        switch result {
        case .success(let scoped):
            scoped.stopAccessing()
            return true
        case .failure:
            return false
        }
    }

    func modificationDate(for project: WatchedProject) -> Date? {
        let result = accessProjectURL(project)
        switch result {
        case .success(let scoped):
            defer { scoped.stopAccessing() }
            let attrs = try? FileManager.default.attributesOfItem(atPath: scoped.url.path)
            return attrs?[.modificationDate] as? Date
        case .failure:
            return nil
        }
    }

    func detectRepository(for project: WatchedProject) -> GitRepositoryInfo {
        let accessResult = accessProjectURL(project)

        switch accessResult {
        case .failure(let status):
            return GitRepositoryInfo(
                selectedPath: project.path,
                repoRootPath: nil,
                status: status,
                checkedAt: Date()
            )

        case .success(let scoped):
            defer { scoped.stopAccessing() }

            let result = runGitSync(arguments: [
                "-C", scoped.url.path,
                "rev-parse", "--show-toplevel"
            ])

            guard result.exitCode == 0 else {
                if result.stderr.localizedCaseInsensitiveContains("not a git repository") {
                    return GitRepositoryInfo(
                        selectedPath: scoped.url.path,
                        repoRootPath: nil,
                        status: .notGitRepository,
                        checkedAt: Date()
                    )
                }

                return GitRepositoryInfo(
                    selectedPath: scoped.url.path,
                    repoRootPath: nil,
                    status: .error(message: cleanGitError(result.stderr)),
                    checkedAt: Date()
                )
            }

            let repoRoot = result.stdout
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let selectedPath = scoped.url.path

            let status: GitRepositoryStatus
            if repoRoot == selectedPath {
                status = .gitRepoRoot
            } else {
                status = .insideGitRepo(repoRootPath: repoRoot)
            }

            return GitRepositoryInfo(
                selectedPath: selectedPath,
                repoRootPath: repoRoot,
                status: status,
                checkedAt: Date()
            )
        }
    }

    func totalLOC(for project: WatchedProject) -> LOCSummary {
        let repoInfo = detectRepository(for: project)

        guard repoInfo.canTrackLOC else {
            return convertToUnavailable(repoInfo.status)
        }

        let accessResult = accessProjectURL(project)

        switch accessResult {
        case .failure(let status):
            return .unavailable(.permissionDenied(status.message))

        case .success(let scoped):
            defer { scoped.stopAccessing() }

            guard let repoRoot = repoInfo.repoRootPath else {
                return .unavailable(.notGitRepository)
            }

            guard canAccessRepoRoot(repoRoot, fromSelectedURL: scoped.url) else {
                return .unavailable(.permissionDenied(
                    "Git repo root is outside the selected folder. Please add the repository root folder for LOC tracking: \(repoRoot)"
                ))
            }

            let unstagedResult = runGitSync(arguments: [
                "-C", repoRoot,
                "diff", "--numstat"
            ])

            let stagedResult = runGitSync(arguments: [
                "-C", repoRoot,
                "diff", "--cached", "--numstat"
            ])

            let committedResult = runGitSync(arguments: [
                "-C", repoRoot,
                "log", "--since=midnight", "--numstat", "--pretty=format:"
            ])

            if unstagedResult.exitCode != 0 || stagedResult.exitCode != 0 || committedResult.exitCode != 0 {
                let errors = [
                    unstagedResult.exitCode != 0 ? "unstaged: \(cleanGitError(unstagedResult.stderr))" : nil,
                    stagedResult.exitCode != 0 ? "staged: \(cleanGitError(stagedResult.stderr))" : nil,
                    committedResult.exitCode != 0 ? "committed: \(cleanGitError(committedResult.stderr))" : nil
                ].compactMap { $0 }.joined(separator: "; ")

                return .unavailable(.gitError(errors.isEmpty ? "Git command failed." : errors))
            }

            let unstagedLOC = parseNumstat(unstagedResult.stdout)
            let stagedLOC = parseNumstat(stagedResult.stdout)
            let committedLOC = parseNumstat(committedResult.stdout)

            let totalAdded = unstagedLOC.linesAdded + stagedLOC.linesAdded + committedLOC.linesAdded
            let totalDeleted = unstagedLOC.linesDeleted + stagedLOC.linesDeleted + committedLOC.linesDeleted
            let totalFiles = unstagedLOC.filesChanged + stagedLOC.filesChanged + committedLOC.filesChanged

            return LOCSummary(
                linesAdded: totalAdded,
                linesDeleted: totalDeleted,
                filesChanged: totalFiles,
                status: .ready,
                lastUpdatedAt: Date()
            )
        }
    }

    func changedFiles(for project: WatchedProject) -> [String] {
        let accessResult = accessProjectURL(project)

        switch accessResult {
        case .failure:
            return []

        case .success(let scoped):
            defer { scoped.stopAccessing() }

            let result = runGitSync(arguments: [
                "-C", scoped.url.path,
                "diff", "--name-only"
            ])

            guard result.exitCode == 0 else {
                return []
            }

            return result.stdout
                .split(separator: "\n")
                .map(String.init)
                .filter { !shouldIgnore(path: $0) }
        }
    }

    func workingTreeLOC(for project: WatchedProject) -> LOCSummary {
        let accessResult = accessProjectURL(project)

        switch accessResult {
        case .failure(let status):
            return .unavailable(.permissionDenied(status.message))

        case .success(let scoped):
            defer { scoped.stopAccessing() }

            let unstagedResult = runGitSync(arguments: [
                "-C", scoped.url.path,
                "diff", "--numstat"
            ])

            let stagedResult = runGitSync(arguments: [
                "-C", scoped.url.path,
                "diff", "--cached", "--numstat"
            ])

            guard unstagedResult.exitCode == 0 && stagedResult.exitCode == 0 else {
                return .unavailable(.gitError("Git working tree diff failed."))
            }

            let unstaged = parseNumstat(unstagedResult.stdout)
            let staged = parseNumstat(stagedResult.stdout)

            return LOCSummary(
                linesAdded: unstaged.linesAdded + staged.linesAdded,
                linesDeleted: unstaged.linesDeleted + staged.linesDeleted,
                filesChanged: unstaged.filesChanged + staged.filesChanged,
                status: .ready,
                lastUpdatedAt: Date()
            )
        }
    }

    func committedLOCToday(for project: WatchedProject) -> LOCSummary {
        let accessResult = accessProjectURL(project)

        switch accessResult {
        case .failure(let status):
            return .unavailable(.permissionDenied(status.message))

        case .success(let scoped):
            defer { scoped.stopAccessing() }

            let result = runGitSync(arguments: [
                "-C", scoped.url.path,
                "log", "--since=midnight", "--numstat", "--pretty=format:"
            ])

            guard result.exitCode == 0 else {
                return .unavailable(.gitError("Git log for today's commits failed."))
            }

            return parseNumstat(result.stdout)
        }
    }
}

// MARK: - Helpers

extension GitLOCTracker {
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

    private func parseNumstat(_ output: String) -> LOCSummary {
        var added = 0
        var deleted = 0
        var files = 0

        let lines = output
            .split(separator: "\n")
            .map(String.init)

        for line in lines {
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

            files += 1
        }

        return LOCSummary(
            linesAdded: added,
            linesDeleted: deleted,
            filesChanged: files,
            status: .ready,
            lastUpdatedAt: Date()
        )
    }

    private func shouldIgnore(path: String) -> Bool {
        let normalized = "/" + path

        if Self.ignoredPathFragments.contains(where: { normalized.contains($0) }) {
            return true
        }

        if Self.ignoredFilenameFragments.contains(where: { path.contains($0) }) {
            return true
        }

        return false
    }

    private func convertToUnavailable(_ status: GitRepositoryStatus) -> LOCSummary {
        switch status {
        case .notGitRepository:
            return .unavailable(.notGitRepository)
        case .permissionDenied(let message):
            return .unavailable(.permissionDenied(message))
        case .gitUnavailable(let message):
            return .unavailable(.gitUnavailable(message))
        case .error(let message):
            return .unavailable(.gitError(message))
        default:
            return .unavailable(.unknown)
        }
    }
}

// MARK: - Git Execution

extension GitLOCTracker {
    private func runGitSync(arguments: [String]) -> GitCommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

            let stdout = String(data: outputData, encoding: .utf8) ?? ""
            let stderr = String(data: errorData, encoding: .utf8) ?? ""

            return GitCommandResult(
                stdout: stdout,
                stderr: stderr,
                exitCode: process.terminationStatus
            )
        } catch {
            return GitCommandResult(
                stdout: "",
                stderr: error.localizedDescription,
                exitCode: -1
            )
        }
    }

    private func cleanGitError(_ error: String) -> String {
        let trimmed = error.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "Git command failed with no error message."
        }

        return String(trimmed.prefix(500))
    }

    private func canAccessRepoRoot(_ repoRoot: String, fromSelectedURL selectedURL: URL) -> Bool {
        let selectedPath = selectedURL.path

        if repoRoot == selectedPath {
            return true
        }

        if repoRoot.hasPrefix(selectedPath + "/") {
            return true
        }

        return false
    }
}

// MARK: - Security Scoped Access

extension GitLOCTracker {
    private struct ScopedProjectURL {
        let url: URL
        let didStartAccessing: Bool

        func stopAccessing() {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
    }

    private enum ProjectAccessResult {
        case success(ScopedProjectURL)
        case failure(GitRepositoryStatus)
    }

    private func accessProjectURL(_ project: WatchedProject) -> ProjectAccessResult {
        do {
            let url: URL

            if let bookmarkData = project.bookmarkData {
                var isStale = false

                url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: [.withSecurityScope],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
            } else {
                print("[GitLOCTracker] accessProjectURL: \(project.name) has NO bookmark data")
                url = URL(fileURLWithPath: project.path)
            }

            let didStartAccessing = url.startAccessingSecurityScopedResource()

            if project.bookmarkData != nil, !didStartAccessing {
                print("[GitLOCTracker] accessProjectURL: \(project.name) startAccessingSecurityScopedResource FAILED")
                return .failure(.permissionDenied(
                    message: "Security-scoped access failed for \(project.name). Please re-add this folder."
                ))
            }

            return .success(ScopedProjectURL(
                url: url,
                didStartAccessing: didStartAccessing
            ))
        } catch {
            print("[GitLOCTracker] accessProjectURL: \(project.name) error=\(error.localizedDescription)")
            return .failure(.permissionDenied(
                message: error.localizedDescription
            ))
        }
    }
}

// MARK: - Git Command Result

struct GitCommandResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32

    var isSuccess: Bool {
        exitCode == 0
    }
}
