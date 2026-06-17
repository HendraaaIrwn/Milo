//
//  AppleFoundationModelsResponseGenerator.swift
//  Milo
//
//  PRIVACY: Only receives sanitized MiloSmartPersonalityInput.
//  Never sends typed text, source code, clipboard, or private content to the model.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
final class AppleFoundationModelsResponseGenerator: MiloAIResponseGenerating {
    func generateResponse(
        input: MiloSmartPersonalityInput,
        settings: MiloPersonalitySettings
    ) async throws -> String {
        #if canImport(FoundationModels)
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await self.generateWithFoundationModels(input: input, settings: settings)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(settings.aiTimeoutSeconds * 1_000_000_000))
                throw MiloAIResponseError.timeout
            }
            guard let result = try await group.next() else {
                throw MiloAIResponseError.emptyResponse
            }
            group.cancelAll()
            return result
        }
        #else
        throw MiloAIResponseError.unavailable
        #endif
    }

    #if canImport(FoundationModels)
    private func generateWithFoundationModels(
        input: MiloSmartPersonalityInput,
        settings: MiloPersonalitySettings
    ) async throws -> String {
        // TODO: Replace with actual FoundationModels API call when macOS 26 SDK ships.
        //
        // Example implementation:
        //   let model = SystemLanguageModel.default
        //   let instructions = "You are MILO, a tiny coding companion..."
        //   let session = LanguageModelSession(model: model, instructions: instructions)
        //   let prompt = MiloSmartPersonalityPromptBuilder().buildPrompt(from: input)
        //   let response = try await session.respond(to: prompt)
        //   return response.content
        //
        throw MiloAIResponseError.unavailable
    }
    #endif
}
