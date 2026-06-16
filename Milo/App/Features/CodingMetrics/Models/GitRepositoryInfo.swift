//
//  GitRepositoryInfo.swift
//  Milo
//
//  PRIVACY: Stores Git repo metadata only. No source code content is stored.
//

import Foundation

struct GitRepositoryInfo: Codable, Equatable {
    let selectedPath: String
    let repoRootPath: String?
    let status: GitRepositoryStatus
    let checkedAt: Date

    var canTrackLOC: Bool {
        status.canTrackLOC
    }

    init(
        selectedPath: String,
        repoRootPath: String?,
        status: GitRepositoryStatus,
        checkedAt: Date = Date()
    ) {
        self.selectedPath = selectedPath
        self.repoRootPath = repoRootPath
        self.status = status
        self.checkedAt = checkedAt
    }
}
