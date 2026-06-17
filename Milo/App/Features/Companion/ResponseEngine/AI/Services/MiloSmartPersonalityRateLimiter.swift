//
//  MiloSmartPersonalityRateLimiter.swift
//  Milo
//

import Foundation

struct MiloSmartPersonalityRateLimiter {
    private var lastAIResponseAtByEvent: [MiloResponseEvent: Date] = [:]

    mutating func shouldAllowAI(for event: MiloResponseEvent) -> Bool {
        let now = Date()
        let cooldown: TimeInterval

        switch event {
        case .typingDetected:   cooldown = 30
        case .miloClicked:      cooldown = 4
        case .returnedFromIdle: cooldown = 20
        default:                cooldown = 10
        }

        if let last = lastAIResponseAtByEvent[event],
           now.timeIntervalSince(last) < cooldown {
            return false
        }

        lastAIResponseAtByEvent[event] = now
        return true
    }
}
