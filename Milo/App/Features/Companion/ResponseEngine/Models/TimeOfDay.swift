//
//  TimeOfDay.swift
//  Milo
//

import Foundation

enum TimeOfDay: String, Codable, Equatable {
    case morning
    case afternoon
    case evening
    case lateNight
    case unknown

    static func from(_ date: Date = Date(), calendar: Calendar = .current) -> TimeOfDay {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12:  return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        case 22...23, 0..<5: return .lateNight
        default: return .unknown
        }
    }
}
