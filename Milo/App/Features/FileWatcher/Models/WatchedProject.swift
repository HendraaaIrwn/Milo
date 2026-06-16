//
//  WatchedProject.swift
//  Milo
//
//  PRIVACY: MILO stores only user-chosen folder paths and file metadata.
//  No source code content or file contents are stored.
//

import Foundation

struct WatchedProject: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var path: String
    var bookmarkData: Data?
    var isEnabled: Bool
    var addedAt: Date
    var lastActivityAt: Date?
    var lastKnownTopLanguage: String?
    var gitRepositoryInfo: GitRepositoryInfo?
    var lastLOCSummary: LOCSummary?

    init(
        id: UUID = UUID(),
        name: String,
        path: String,
        bookmarkData: Data? = nil,
        isEnabled: Bool = true,
        addedAt: Date = Date(),
        lastActivityAt: Date? = nil,
        lastKnownTopLanguage: String? = nil,
        gitRepositoryInfo: GitRepositoryInfo? = nil,
        lastLOCSummary: LOCSummary? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.bookmarkData = bookmarkData
        self.isEnabled = isEnabled
        self.addedAt = addedAt
        self.lastActivityAt = lastActivityAt
        self.lastKnownTopLanguage = lastKnownTopLanguage
        self.gitRepositoryInfo = gitRepositoryInfo
        self.lastLOCSummary = lastLOCSummary
    }
}
