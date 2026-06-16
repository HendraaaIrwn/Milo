//
//  GitRepositoryStatus.swift
//  Milo
//
//  PRIVACY: This enum describes Git repository status only. No source code content is stored.
//

import Foundation

enum GitRepositoryStatus: Codable, Equatable {
    case unknown
    case checking
    case gitRepoRoot
    case insideGitRepo(repoRootPath: String)
    case notGitRepository
    case permissionDenied(message: String)
    case gitUnavailable(message: String)
    case error(message: String)

    var canTrackLOC: Bool {
        switch self {
        case .gitRepoRoot:
            return true
        case .insideGitRepo:
            return true
        default:
            return false
        }
    }

    var title: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .checking:
            return "Checking..."
        case .gitRepoRoot:
            return "Git Repo"
        case .insideGitRepo:
            return "Inside Git Repo"
        case .notGitRepository:
            return "Not Git Repo"
        case .permissionDenied:
            return "Permission Denied"
        case .gitUnavailable:
            return "Git Unavailable"
        case .error:
            return "Git Error"
        }
    }

    var message: String {
        switch self {
        case .unknown:
            return "Git status has not been checked yet."
        case .checking:
            return "Checking Git repository status..."
        case .gitRepoRoot:
            return "This folder is a Git repository root and can be tracked."
        case .insideGitRepo(let repoRootPath):
            return "This folder is inside a Git repository. Repo root: \(repoRootPath)"
        case .notGitRepository:
            return "This folder is not inside a Git repository, so LOC tracking is unavailable."
        case .permissionDenied(let message):
            return "MILO cannot access this folder for Git LOC tracking. \(message)"
        case .gitUnavailable(let message):
            return "MILO could not run Git. \(message)"
        case .error(let message):
            return message
        }
    }
}
