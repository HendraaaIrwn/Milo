//
//  MiloPersonalitySettings.swift
//  Milo
//

import Foundation

enum MiloResponseMode: String, Codable, CaseIterable, Identifiable {
    case classicLocal
    case smartLocal
    case smartPersonality

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classicLocal:      return "Classic Local"
        case .smartLocal:        return "Smart Local"
        case .smartPersonality:  return "Smart Personality"
        }
    }

    var subtitle: String {
        switch self {
        case .classicLocal:
            return "Simple local response lines."
        case .smartLocal:
            return "Context-aware local responses, no AI."
        case .smartPersonality:
            return "Apple Intelligence enhanced responses."
        }
    }
}

enum MiloPersonalityTone: String, Codable, CaseIterable, Identifiable {
    case friendly
    case playful
    case tinyRoast
    case calm
    case focusCoach

    var id: String { rawValue }
}

struct MiloPersonalitySettings: Codable, Equatable {
    var responseMode: MiloResponseMode = .smartLocal
    var smartPersonalityEnabled: Bool = false

    var allowProjectName: Bool = false
    var allowActiveLanguage: Bool = true
    var allowCodingDuration: Bool = true
    var allowTypingIntensity: Bool = true
    var allowTodoCounts: Bool = true
    var allowPomodoroState: Bool = true

    var allowPlayfulRoast: Bool = true
    var tone: MiloPersonalityTone = .playful
    var maxResponseWords: Int = 18
    var aiTimeoutSeconds: TimeInterval = 2.5
}
