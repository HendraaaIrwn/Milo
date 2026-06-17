//
//  CategoryBreakdown.swift
//  Milo
//
//  PRIVACY: Aggregated safe metadata only. No source code or private content.
//

import Foundation

struct CategoryBreakdown: Identifiable, Codable, Equatable {
    var id: String { name }
    let name: String
    let minutes: Int
    let percentage: Double
}
