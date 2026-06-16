//
//  DailyCodingMetricsRecord.swift
//  Milo
//
//  PRIVACY: MILO Weekly Coding Summary stores only local metadata:
//  coding time, editor name, project name/path, estimated language, LOC summary, and sessions.
//  MILO does not store source code content or full file contents.
//  Local metrics are not uploaded.
//

import Foundation

struct DailyCodingMetricsRecord: Codable, Identifiable, Equatable {
    var id: String { dateKey }

    let dateKey: String
    var date: Date

    var codingSeconds: Int
    var sessionCount: Int

    var topLanguage: String?
    var topProject: String?
    var topEditor: String?

    var locSummary: LOCSummary

    var languageSeconds: [String: Int]
    var projectSeconds: [String: Int]
    var editorSeconds: [String: Int]

    var lastUpdatedAt: Date

    init(
        dateKey: String,
        date: Date = Date(),
        codingSeconds: Int = 0,
        sessionCount: Int = 0,
        topLanguage: String? = nil,
        topProject: String? = nil,
        topEditor: String? = nil,
        locSummary: LOCSummary = .empty,
        languageSeconds: [String: Int] = [:],
        projectSeconds: [String: Int] = [:],
        editorSeconds: [String: Int] = [:],
        lastUpdatedAt: Date = Date()
    ) {
        self.dateKey = dateKey
        self.date = date
        self.codingSeconds = codingSeconds
        self.sessionCount = sessionCount
        self.topLanguage = topLanguage
        self.topProject = topProject
        self.topEditor = topEditor
        self.locSummary = locSummary
        self.languageSeconds = languageSeconds
        self.projectSeconds = projectSeconds
        self.editorSeconds = editorSeconds
        self.lastUpdatedAt = lastUpdatedAt
    }
}
