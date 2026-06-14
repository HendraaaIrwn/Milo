//
//  CodingLanguageMetric.swift
//  Milo
//
//  PRIVACY: Language is estimated from file extensions only. Source code content is never read.
//

import Foundation

struct CodingLanguageMetric: Codable, Identifiable, Equatable {
    let id: UUID
    var language: String
    var seconds: Int
    var filesTouched: Int
    var linesAdded: Int
    var linesDeleted: Int

    init(
        id: UUID = UUID(),
        language: String,
        seconds: Int = 0,
        filesTouched: Int = 0,
        linesAdded: Int = 0,
        linesDeleted: Int = 0
    ) {
        self.id = id
        self.language = language
        self.seconds = seconds
        self.filesTouched = filesTouched
        self.linesAdded = linesAdded
        self.linesDeleted = linesDeleted
    }
}
