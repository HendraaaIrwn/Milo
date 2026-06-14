//
//  ActiveProjectDetector.swift
//  Milo
//
//  PRIVACY: MILO only inspects folder modification dates and the existence of a .git directory. No file contents are read.
//

import Foundation

struct ActiveProjectInfo: Equatable {
    let name: String
    let path: String
}

struct ActiveProjectDetector {
    static func detectProject(from projectPaths: [String]) -> ActiveProjectInfo? {
        let existingPaths = projectPaths
            .map { URL(fileURLWithPath: $0) }
            .filter { FileManager.default.fileExists(atPath: $0.path) }

        let sorted = existingPaths.sorted { lhs, rhs in
            let lhsDate = modificationDate(for: lhs) ?? .distantPast
            let rhsDate = modificationDate(for: rhs) ?? .distantPast
            return lhsDate > rhsDate
        }

        guard let selected = sorted.first else {
            return nil
        }

        return ActiveProjectInfo(
            name: selected.lastPathComponent,
            path: selected.path
        )
    }

    private static func modificationDate(for url: URL) -> Date? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return nil
        }

        return attributes[.modificationDate] as? Date
    }
}
