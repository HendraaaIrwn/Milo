//
//  MiloMood.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import Foundation

/// Visual / behavioral state of the Milo companion.
///
/// The mood influences which facial assets are rendered and how
/// the blink + gaze engines behave.
enum MiloMood: String, CaseIterable, Identifiable {
    case idle
    case typing
    case happy
    case confused
    case sleepy
    case reminder
    case focus

    var id: String { rawValue }

    /// Probability of triggering a blink within a one-second window.
    /// Sleepy state blinks more frequently; focus keeps it minimal.
    var blinkFrequencyPerSecond: Double {
        switch self {
        case .sleepy: 0.55
        case .idle:   0.25
        case .happy:  0.35
        case .typing: 0.30
        case .confused, .reminder, .focus: 0.15
        }
    }
}
