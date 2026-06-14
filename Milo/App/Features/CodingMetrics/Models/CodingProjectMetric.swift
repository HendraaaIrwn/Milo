//
//  CodingProjectMetric.swift
//  Milo
//
//  PRIVACY: MILO stores the project folder path chosen by the user, not the contents of files inside it.
//

import Foundation

struct CodingProjectMetric: Codable, Identifiable, Equatable {
    let id: UUID
    var projectName: String
    var projectPath: String?
    var seconds: Int
    var linesAdded: Int
    var linesDeleted: Int
    var lastActiveAt: Date

    init(
        id: UUID = UUID(),
        projectName: String,
        projectPath: String? = nil,
        seconds: Int = 0,
        linesAdded: Int = 0,
        linesDeleted: Int = 0,
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.projectName = projectName
        self.projectPath = projectPath
        self.seconds = seconds
        self.linesAdded = linesAdded
        self.linesDeleted = linesDeleted
        self.lastActiveAt = lastActiveAt
    }
}
