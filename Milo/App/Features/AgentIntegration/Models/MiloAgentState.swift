//
//  MiloAgentState.swift
//  Milo
//

import Foundation

enum MiloAgentState: String, Codable, Equatable {
    case idle
    case thinking
    case running
    case waitingForUserInput
    case done
    case failed
    case needsReview
}
