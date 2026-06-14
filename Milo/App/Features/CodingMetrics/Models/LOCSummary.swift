//
//  LOCSummary.swift
//  Milo
//
//  PRIVACY: MILO only stores Git diff/numstat summaries. Source code content is never read or stored.
//

import Foundation

struct LOCSummary: Codable, Equatable {
    var linesAdded: Int
    var linesDeleted: Int

    var netLines: Int {
        linesAdded - linesDeleted
    }

    static let empty = LOCSummary(
        linesAdded: 0,
        linesDeleted: 0
    )
}
