//
//  ProjectFileEvent.swift
//  Milo
//
//  PRIVACY: MILO tracks only file metadata: path, extension, event type, timestamp.
//  File contents are never read or stored.
//

import Foundation

struct ProjectFileEvent: Codable, Identifiable, Equatable {
    let id: UUID
    let projectID: UUID
    let projectName: String
    let projectPath: String
    let filePath: String
    let relativePath: String
    let eventType: ProjectFileEventType
    let language: String?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        projectID: UUID,
        projectName: String,
        projectPath: String,
        filePath: String,
        relativePath: String,
        eventType: ProjectFileEventType,
        language: String?,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.projectID = projectID
        self.projectName = projectName
        self.projectPath = projectPath
        self.filePath = filePath
        self.relativePath = relativePath
        self.eventType = eventType
        self.language = language
        self.timestamp = timestamp
    }
}

enum ProjectFileEventType: String, Codable, Equatable {
    case created
    case modified
    case deleted
    case renamed
    case unknown
}
