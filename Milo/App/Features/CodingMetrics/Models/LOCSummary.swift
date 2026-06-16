//
//  LOCSummary.swift
//  Milo
//
//  PRIVACY: MILO only stores Git diff/numstat summaries. Source code content is never read or stored.
//

import Foundation

struct LOCSummary: Codable, Equatable {
    var linesAdded: Int
    var linesDeleted: Int
    var filesChanged: Int
    var status: LOCSummaryStatus
    var lastUpdatedAt: Date?

    static let empty = LOCSummary(
        linesAdded: 0,
        linesDeleted: 0,
        filesChanged: 0,
        status: .unknown,
        lastUpdatedAt: nil
    )

    static func unavailable(_ status: LOCSummaryStatus) -> LOCSummary {
        LOCSummary(
            linesAdded: 0,
            linesDeleted: 0,
            filesChanged: 0,
            status: status,
            lastUpdatedAt: Date()
        )
    }

    var netLines: Int {
        linesAdded - linesDeleted
    }
}

enum LOCSummaryStatus: Codable, Equatable {
    case unknown
    case ready
    case notGitRepository
    case permissionDenied(String)
    case gitUnavailable(String)
    case gitError(String)

    var title: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .ready:
            return "Ready"
        case .notGitRepository:
            return "Not Git Repo"
        case .permissionDenied:
            return "Permission Denied"
        case .gitUnavailable:
            return "Git Unavailable"
        case .gitError:
            return "Git Error"
        }
    }

    var message: String {
        switch self {
        case .unknown:
            return "LOC status has not been checked yet."
        case .ready:
            return "LOC tracking is available."
        case .notGitRepository:
            return "This folder is not a Git repository."
        case .permissionDenied(let message):
            return message
        case .gitUnavailable(let message):
            return message
        case .gitError(let message):
            return message
        }
    }
}
