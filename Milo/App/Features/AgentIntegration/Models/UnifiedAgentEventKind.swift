//
//  UnifiedAgentEventKind.swift
//  Milo
//

import Foundation

enum UnifiedAgentEventKind: String, Codable, Equatable {
    case sessionStarted
    case promptSubmitted
    case thinking
    case toolStarted
    case toolFinished
    case permissionRequested
    case waitingForInput
    case taskFinished
    case taskFailed
    case subtaskStarted
    case subtaskFinished
    case compacting
    case sessionEnded
    case unknown
}
