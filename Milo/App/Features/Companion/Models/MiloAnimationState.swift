//
//  MiloAnimationState.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

/// PRIVACY: MILO only detects keyboard activity timing.
/// Actual typed characters, key codes, and input content are never read or stored.
enum MiloAnimationState: Equatable {
    case idle
    case typing(intensity: TypingIntensity)
    case happy
    case thinking
    case reminder
    case breakTime
}

enum TypingIntensity: String, Codable, Equatable {
    case inactive
    case slow
    case normal
    case fast
}

extension MiloAnimationState {
    var miloMood: MiloMood {
        switch self {
        case .idle:                     .idle
        case .typing:                   .typing
        case .happy:                    .happy
        case .thinking:                 .focus
        case .reminder:                 .reminder
        case .breakTime:                .sleepy
        }
    }
}
