//
//  MiloMoodDetector.swift
//  Milo
//

import Foundation

struct MiloMoodDetector {
    func detectMood(from context: CodingContext) -> MiloResponseMood {
        if context.idleMinutes >= 15 {
            return .comeback
        }
        if context.currentFocusMinutes >= 120 {
            return .overworked
        }
        if context.currentFocusMinutes >= 45 && (context.typingIntensity == .fast || context.typingIntensity == .normal) {
            return .focused
        }
        if context.typingIntensity == .fast {
            return .energetic
        }
        if context.activeCodingMinutesToday >= 180 && context.skippedBreakCountToday > 0 {
            return .tired
        }
        if context.completedPomodoroCountToday > 0 {
            return .celebrating
        }
        if context.typingIntensity == .inactive {
            return .idle
        }
        return .neutral
    }
}
