//
//  ProjectFolderIgnoreRules.swift
//  Milo
//
//  PRIVACY: MILO ignores dependency, build, and generated directories.
//  Only user source files contribute to file activity tracking.
//

import Foundation

struct ProjectFolderIgnoreRules {
    static let ignoredDirectoryNames: Set<String> = [
        "node_modules",
        ".git",
        "build",
        "dist",
        "DerivedData",
        "vendor",
        ".next",
        ".nuxt",
        ".svelte-kit",
        "coverage",
        "Pods",
        "Carthage",
        ".swiftpm"
    ]

    static let ignoredFilenameFragments: [String] = [
        ".min.js",
        ".min.css",
        ".generated.",
        ".pbxproj"
    ]

    static let ignoredExtensions: Set<String> = [
        "lock",
        "tmp",
        "log",
        "DS_Store"
    ]

    static func shouldIgnore(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)

        for component in url.pathComponents {
            if ignoredDirectoryNames.contains(component) {
                return true
            }
        }

        let filename = url.lastPathComponent

        if ignoredFilenameFragments.contains(where: { filename.contains($0) }) {
            return true
        }

        let ext = url.pathExtension

        if ignoredExtensions.contains(ext) {
            return true
        }

        return false
    }

    static func relativePath(filePath: String, projectPath: String) -> String {
        if filePath.hasPrefix(projectPath) {
            let startIndex = filePath.index(filePath.startIndex, offsetBy: projectPath.count)
            return String(filePath[startIndex...])
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }

        return URL(fileURLWithPath: filePath).lastPathComponent
    }
}
