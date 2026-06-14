//
//  CodingSession.swift
//  Milo
//
//  PRIVACY: A session stores only timing, editor/project names, estimated languages, and LOC summary. No source code.
//

import Foundation

struct CodingSession: Codable, Identifiable, Equatable {
    let id: UUID
    var startedAt: Date
    var endedAt: Date?
    var activeSeconds: Int
    var editorName: String?
    var projectName: String?
    var projectPath: String?
    var languages: [String]
    var locSummary: LOCSummary

    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        activeSeconds: Int = 0,
        editorName: String? = nil,
        projectName: String? = nil,
        projectPath: String? = nil,
        languages: [String] = [],
        locSummary: LOCSummary = .empty
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.activeSeconds = activeSeconds
        self.editorName = editorName
        self.projectName = projectName
        self.projectPath = projectPath
        self.languages = languages
        self.locSummary = locSummary
    }
}
