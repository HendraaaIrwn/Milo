//
//  MiloSmartPersonalityEngine.swift
//  Milo
//
//  PRIVACY: Routes responses through local or AI pipeline based on settings.
//  Always runs local engine first for cooldown/mood/intent. AI is opt-in enhancement.
//

import Foundation

@MainActor
final class MiloSmartPersonalityEngine {
    private let localEngine: MiloContextAwareResponseEngine
    private let aiGenerator: MiloAIResponseGenerating?
    private let availabilityService: AppleIntelligenceAvailabilityService
    private let settingsStore: MiloPersonalitySettingsStore

    private let inputBuilder = MiloSmartPersonalityInputBuilder()
    private let safetyFilter = MiloAIResponseSafetyFilter()
    private let moodDetector = MiloMoodDetector()
    private let intentPlanner = MiloResponseIntentPlanner()
    private var rateLimiter = MiloSmartPersonalityRateLimiter()

    init(
        localEngine: MiloContextAwareResponseEngine,
        aiGenerator: MiloAIResponseGenerating? = nil,
        availabilityService: AppleIntelligenceAvailabilityService,
        settingsStore: MiloPersonalitySettingsStore
    ) {
        self.localEngine = localEngine
        self.aiGenerator = aiGenerator
        self.availabilityService = availabilityService
        self.settingsStore = settingsStore
    }

    func generateResponse(
        event: MiloResponseEvent,
        context: CodingContext
    ) async -> String? {
        let localResponse = localEngine.generateResponse(event: event, context: context)

        let settings = settingsStore.settings

        guard settings.responseMode == .smartPersonality,
              settings.smartPersonalityEnabled,
              availabilityService.status == .available,
              rateLimiter.shouldAllowAI(for: event)
        else {
            return localResponse
        }

        let mood = moodDetector.detectMood(from: context)
        let intent = intentPlanner.chooseIntent(event: event, context: context, mood: mood)

        let input = inputBuilder.build(
            event: event,
            intent: intent,
            mood: mood,
            context: context,
            localCandidate: localResponse,
            settings: settings
        )

        do {
            guard let aiGenerator else { return localResponse }

            let rawResponse = try await aiGenerator.generateResponse(
                input: input,
                settings: settings
            )

            if let safe = safetyFilter.sanitize(rawResponse, maxWords: settings.maxResponseWords) {
                MiloResponseDebugLogger.log("AI response accepted: \"\(safe)\"")
                return safe
            }

            MiloResponseDebugLogger.log("AI response rejected by safety filter")
        } catch {
            MiloResponseDebugLogger.log("AI generation failed: \(error)")
        }

        return localResponse
    }
}
