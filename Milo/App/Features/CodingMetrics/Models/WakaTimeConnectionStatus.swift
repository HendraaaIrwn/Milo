//
//  WakaTimeConnectionStatus.swift
//  Milo
//
//  PRIVACY: WakaTime API key is stored in macOS Keychain.
//  MILO never logs or displays the full API key.
//

import Foundation

enum WakaTimeConnectionStatus: Equatable, Codable {
    case notConnected
    case checking
    case connected(profile: WakaTimeUserProfile)
    case invalidAPIKey(detail: String?)
    case badRequest(detail: String?)
    case forbidden(detail: String?)
    case rateLimited
    case networkError(message: String)
    case serverError(statusCode: Int)
    case unknownError(message: String)

    var title: String {
        switch self {
        case .notConnected: return "Not Connected"
        case .checking: return "Checking..."
        case .connected: return "Connected"
        case .invalidAPIKey: return "Invalid API Key"
        case .badRequest: return "Bad Request"
        case .forbidden: return "Forbidden"
        case .rateLimited: return "Rate Limited"
        case .networkError: return "Network Error"
        case .serverError: return "Server Error"
        case .unknownError: return "Unknown Error"
        }
    }

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var userMessage: String {
        switch self {
        case .notConnected:
            return "Connect WakaTime to enrich MILO coding metrics."
        case .checking:
            return "Testing your WakaTime connection..."
        case .connected(let profile):
            return "Connected as \(profile.displayNameOrUsername)."
        case .invalidAPIKey(let detail):
            let base = "WakaTime rejected this key. Check whether the key has extra spaces or was regenerated."
            guard let detail, !detail.isEmpty else { return base }
            return "\(base) (\(detail))"
        case .badRequest(let detail):
            return "WakaTime rejected the request. \(detail ?? "Check your API key.")"
        case .forbidden(let detail):
            return "MILO connected, but this key does not have permission. \(detail ?? "")"
        case .rateLimited:
            return "WakaTime is rate limiting requests. Try again in a few minutes."
        case .networkError(let message):
            return "MILO could not reach WakaTime. \(message) Local coding metrics still work."
        case .serverError(let statusCode):
            return "WakaTime returned server error \(statusCode). Try again later."
        case .unknownError(let message):
            return message
        }
    }

    var detailString: String? {
        switch self {
        case .invalidAPIKey(let d): return d
        case .badRequest(let d): return d
        case .forbidden(let d): return d
        case .networkError(let m): return m
        case .unknownError(let m): return m
        default: return nil
        }
    }
}
