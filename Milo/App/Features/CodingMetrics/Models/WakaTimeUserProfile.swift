//
//  WakaTimeUserProfile.swift
//  Milo
//
//  PRIVACY: MILO only stores the WakaTime username/email for display.
//  The API key itself is never displayed or logged.
//

import Foundation

struct WakaTimeUserProfile: Codable, Equatable {
    let id: String?
    let username: String?
    let displayName: String?
    let email: String?
    let photoURL: String?

    var displayNameOrUsername: String {
        if let displayName, !displayName.isEmpty {
            return displayName
        }
        if let username, !username.isEmpty {
            return username
        }
        if let email, !email.isEmpty {
            return email
        }
        return "WakaTime User"
    }
}
