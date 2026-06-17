//
//  MiloResponseTemplate.swift
//  Milo
//

import Foundation

struct MiloResponseTemplate: Identifiable, Codable, Equatable {
    let id: String
    let intent: MiloResponseIntent
    let mood: MiloResponseMood?
    let text: String
    let weight: Int
    let minFocusMinutes: Int?
    let maxFocusMinutes: Int?
    let minCodingMinutesToday: Int?
    let maxCodingMinutesToday: Int?
    let allowedTypingIntensities: [TypingIntensity]?
    let allowedTimesOfDay: [TimeOfDay]?
}
