//
//  MiloAIResponseGenerating.swift
//  Milo
//

import Foundation

protocol MiloAIResponseGenerating {
    func generateResponse(
        input: MiloSmartPersonalityInput,
        settings: MiloPersonalitySettings
    ) async throws -> String
}

enum MiloAIResponseError: Error {
    case unavailable
    case timeout
    case emptyResponse
    case unsafeResponse
}
