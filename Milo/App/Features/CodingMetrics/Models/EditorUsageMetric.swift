//
//  EditorUsageMetric.swift
//  Milo
//
//  PRIVACY: MILO tracks only the editor name and bundle identifier, never the contents of windows or documents.
//

import Foundation

struct EditorUsageMetric: Codable, Identifiable, Equatable {
    let id: UUID
    var editorName: String
    var bundleIdentifier: String?
    var seconds: Int
    var lastActiveAt: Date

    init(
        id: UUID = UUID(),
        editorName: String,
        bundleIdentifier: String? = nil,
        seconds: Int = 0,
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.editorName = editorName
        self.bundleIdentifier = bundleIdentifier
        self.seconds = seconds
        self.lastActiveAt = lastActiveAt
    }
}
