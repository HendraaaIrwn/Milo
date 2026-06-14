//
//  WakaTimeSummary.swift
//  Milo
//
//  PRIVACY: This model only stores aggregated summary data fetched from WakaTime. No local project data is sent.
//

import Foundation

struct WakaTimeSummary: Codable, Equatable {
    var totalSeconds: Int
    var topLanguage: String?
    var topProject: String?
    var editorUsage: [String: Int]
}
