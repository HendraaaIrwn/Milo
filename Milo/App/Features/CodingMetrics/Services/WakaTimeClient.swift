//
//  WakaTimeClient.swift
//  Milo
//
//  PRIVACY: The WakaTime API key is loaded from Keychain.
//  It is never logged, stored in UserDefaults, or displayed in UI.
//  MILO only fetches summary/profile data from WakaTime; local metrics are never uploaded.
//

import Foundation
import OSLog

final class WakaTimeClient: Sendable {
    private let keychain = KeychainService.shared

    private let keychainServiceName = "MILO.WakaTime"
    private let keychainAccountName = "APIKey"

    private static let apiBase = "https://api.wakatime.com/api/v1"

    static let currentUserEndpoint = "\(apiBase)/users/current"

    private let logger = Logger(subsystem: "com.milo", category: "WakaTimeClient")

    // MARK: - Keychain Operations

    func saveAPIKey(_ key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WakaTimeClientError.emptyAPIKey }
        try keychain.save(trimmed, service: keychainServiceName, account: keychainAccountName)
        logger.debug("WakaTime API key saved to Keychain (length: \(trimmed.count))")
    }

    func loadAPIKey() throws -> String? {
        let key = try keychain.load(service: keychainServiceName, account: keychainAccountName)
        logger.debug("WakaTime API key loaded from Keychain (exists: \(key != nil && !(key!).isEmpty))")
        return key
    }

    func deleteAPIKey() {
        keychain.delete(service: keychainServiceName, account: keychainAccountName)
        logger.debug("WakaTime API key deleted from Keychain")
    }

    func hasAPIKey() -> Bool {
        do {
            guard let key = try loadAPIKey() else { return false }
            return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } catch {
            logger.error("WakaTime Keychain access error: \(error.localizedDescription)")
            return false
        }
    }

    func debugKeychainState() -> String {
        do {
            guard let key = try loadAPIKey() else { return "No API key in Keychain" }
            let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return "API key in Keychain but empty" }
            return "API key in Keychain. Length: \(trimmed.count)"
        } catch {
            return "Keychain access failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Connection Test

    func testConnection() async -> WakaTimeConnectionStatus {
        do {
            guard let apiKey = try loadAPIKey(),
                  !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                logger.debug("WakaTime testConnection: no API key in Keychain")
                return .notConnected
            }

            logger.debug("WakaTime testConnection: API key found (length: \(apiKey.count)), sending request")
            let profile = try await fetchCurrentUser(apiKey: apiKey)
            logger.debug("WakaTime testConnection: connected as \(profile.displayNameOrUsername)")
            return .connected(profile: profile)

        } catch WakaTimeClientError.emptyAPIKey {
            return .notConnected
        } catch WakaTimeClientError.invalidAPIKey(let msg) {
            return .invalidAPIKey(detail: msg)
        } catch WakaTimeClientError.badRequest(let msg) {
            return .badRequest(detail: msg)
        } catch WakaTimeClientError.forbidden(let msg) {
            return .forbidden(detail: msg)
        } catch WakaTimeClientError.rateLimited {
            return .rateLimited
        } catch WakaTimeClientError.serverError(let statusCode) {
            return .serverError(statusCode: statusCode)
        } catch WakaTimeClientError.keychainError(let msg) {
            return .unknownError(message: "Keychain error: \(msg)")
        } catch WakaTimeClientError.networkError(let message) {
            return .networkError(message: message)
        } catch WakaTimeClientError.decodingError(let message) {
            return .unknownError(message: "WakaTime responded, but MILO could not read the response: \(message)")
        } catch {
            logger.error("WakaTime testConnection unexpected error: \(error.localizedDescription)")
            return .unknownError(message: error.localizedDescription)
        }
    }

    // MARK: - Daily Summary

    func fetchTodaySummary() async throws -> WakaTimeSummary? {
        guard let apiKey = try loadAPIKey(), !apiKey.isEmpty else { return nil }

        var components = URLComponents(string: "\(Self.apiBase)/users/current/summaries")!
        let today = dateString(Date())
        components.queryItems = [
            URLQueryItem(name: "start", value: today),
            URLQueryItem(name: "end", value: today)
        ]

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue(makeBasicAuthHeader(apiKey: apiKey), forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode)
        else { return nil }

        return try parseSummary(data)
    }

    // MARK: - Fetch User Profile

    private func fetchCurrentUser(apiKey: String) async throws -> WakaTimeUserProfile {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { throw WakaTimeClientError.emptyAPIKey }

        guard let url = URL(string: Self.currentUserEndpoint) else {
            throw WakaTimeClientError.networkError("Invalid URL.")
        }

        logger.debug("WakaTime request: GET \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue(makeBasicAuthHeader(apiKey: trimmedKey), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("MILO-macOS/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw WakaTimeClientError.networkError("Invalid response from WakaTime.")
            }

            logger.debug("WakaTime response: HTTP \(http.statusCode)")

            let safeBody = readSafeErrorBody(data)
            if let body = safeBody {
                logger.debug("WakaTime response body (first 500 chars): \(body)")
            }

            switch http.statusCode {
            case 200:
                do { return try parseUserProfile(data) }
                catch {
                    logger.error("WakaTime decode error: \(error.localizedDescription)")
                    throw WakaTimeClientError.decodingError(error.localizedDescription)
                }

            case 400:
                throw WakaTimeClientError.badRequest(safeBody)

            case 401:
                throw WakaTimeClientError.invalidAPIKey(safeBody)

            case 403:
                throw WakaTimeClientError.forbidden(safeBody)

            case 429:
                throw WakaTimeClientError.rateLimited

            case 500...599:
                throw WakaTimeClientError.serverError(statusCode: http.statusCode)

            default:
                throw WakaTimeClientError.networkError("Unexpected HTTP \(http.statusCode).")
            }
        } catch let urlError as URLError {
            logger.error("WakaTime URLError: \(urlError.localizedDescription)")
            throw WakaTimeClientError.networkError(urlError.localizedDescription)
        } catch let error as WakaTimeClientError {
            throw error
        }
    }

    // MARK: - Parsers

    private func parseUserProfile(_ data: Data) throws -> WakaTimeUserProfile {
        struct Response: Decodable {
            struct UserData: Decodable {
                let id: String?
                let username: String?
                let display_name: String?
                let email: String?
                let photo: String?
            }
            let data: UserData
        }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return WakaTimeUserProfile(
            id: decoded.data.id,
            username: decoded.data.username,
            displayName: decoded.data.display_name,
            email: decoded.data.email,
            photoURL: decoded.data.photo
        )
    }

    private func parseSummary(_ data: Data) throws -> WakaTimeSummary {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dataArray = json?["data"] as? [[String: Any]], let firstDay = dataArray.first
        else { return WakaTimeSummary(totalSeconds: 0, topLanguage: nil, topProject: nil, editorUsage: [:]) }

        let grandTotal = firstDay["grand_total"] as? [String: Any]
        let totalSeconds = intSeconds(from: grandTotal?["total_seconds"])
        let languages = firstDay["languages"] as? [[String: Any]] ?? []
        let topLanguage = languages.first?["name"] as? String
        let projects = firstDay["projects"] as? [[String: Any]] ?? []
        let topProject = projects.first?["name"] as? String
        let editors = firstDay["editors"] as? [[String: Any]] ?? []
        var editorUsage: [String: Int] = [:]
        for editor in editors {
            guard let name = editor["name"] as? String else { continue }
            editorUsage[name] = intSeconds(from: editor["total_seconds"])
        }
        return WakaTimeSummary(totalSeconds: totalSeconds, topLanguage: topLanguage, topProject: topProject, editorUsage: editorUsage)
    }

    private func intSeconds(from value: Any?) -> Int {
        if let value = value as? Int { return value }
        if let value = value as? Double { return Int(value.rounded()) }
        if let value = value as? String, let seconds = Double(value) { return Int(seconds.rounded()) }
        return 0
    }

    // MARK: - Auth

    private func makeBasicAuthHeader(apiKey: String) -> String {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let encoded = Data(trimmed.utf8).base64EncodedString()
        return "Basic \(encoded)"
    }

    // MARK: - Helpers

    private func readSafeErrorBody(_ data: Data) -> String? {
        guard let raw = String(data: data, encoding: .utf8), !raw.isEmpty else { return nil }
        return String(raw.prefix(500))
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// MARK: - Errors

enum WakaTimeClientError: Error, Equatable {
    case emptyAPIKey
    case invalidAPIKey(String?)
    case badRequest(String?)
    case forbidden(String?)
    case rateLimited
    case serverError(statusCode: Int)
    case networkError(String)
    case decodingError(String)
    case keychainError(String)
}
