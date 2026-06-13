//
//  MiloMood.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import Foundation


enum MiloMood: String, CaseIterable, Identifiable {
    case idle
    case typing
    case happy
    case confused
    case sleepy
    case reminder
    case focus

    var id: String { rawValue }

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
