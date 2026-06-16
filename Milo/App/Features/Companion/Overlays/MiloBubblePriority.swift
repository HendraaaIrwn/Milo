//
//  MiloBubblePriority.swift
//  Milo
//

import Foundation

enum MiloBubblePriority: Int, Codable, Comparable {
    case low = 0
    case normal = 1
    case high = 2
    case critical = 3

    static func < (lhs: MiloBubblePriority, rhs: MiloBubblePriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
