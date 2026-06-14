//
//  WakaTimeClient.swift
//  Milo
//
//  PRIVACY: The WakaTime API key is loaded from Keychain. It is never logged or stored in UserDefaults.
//  MILO only fetches summary data from WakaTime; local metrics are never uploaded.
//

import Foundation

final class WakaTimeClient: Sendable {
    private let keychain = KeychainService.shared

    private let service = "MILO.WakaTime"
    private let account = "APIKey"

    func saveAPIKey(_ key: String) throws {
        try keychain.save(
            key,
            service: service,
            account: account
        )
    }

    func loadAPIKey() throws -> String? {
        try keychain.load(
            service: service,
            account: account
        )
    }

    func deleteAPIKey() {
        keychain.delete(
            service: service,
            account: account
        )
    }

    func fetchTodaySummary() async throws -> WakaTimeSummary? {
        guard let apiKey = try loadAPIKey(),
              !apiKey.isEmpty
        else {
            return nil
        }

        // Use official WakaTime API summary endpoint.
        // Keep this client isolated so endpoint changes are easy to update.

        var components = URLComponents()
        components.scheme = "https"
        components.host = "wakatime.com"
        components.path = "/api/v1/users/current/summaries"

        let today = Self.dateString(Date())

        components.queryItems = [
            URLQueryItem(name: "start", value: today),
            URLQueryItem(name: "end", value: today)
        ]

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        // WakaTime uses the API key as the username with an empty password.
        let credentials = "\(apiKey):".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode)
        else {
            return nil
        }

        return try parseSummary(data)
    }

    private func parseSummary(_ data: Data) throws -> WakaTimeSummary {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let dataArray = json?["data"] as? [[String: Any]],
              let firstDay = dataArray.first
        else {
            return WakaTimeSummary(
                totalSeconds: 0,
                topLanguage: nil,
                topProject: nil,
                editorUsage: [:]
            )
        }

        let grandTotal = firstDay["grand_total"] as? [String: Any]
        let totalSeconds = grandTotal?["total_seconds"] as? Int ?? 0

        let languages = firstDay["languages"] as? [[String: Any]] ?? []
        let topLanguage = languages.first?["name"] as? String

        let projects = firstDay["projects"] as? [[String: Any]] ?? []
        let topProject = projects.first?["name"] as? String

        let editors = firstDay["editors"] as? [[String: Any]] ?? []
        var editorUsage: [String: Int] = [:]

        for editor in editors {
            guard let name = editor["name"] as? String else {
                continue
            }

            let seconds = editor["total_seconds"] as? Int ?? 0
            editorUsage[name] = seconds
        }

        return WakaTimeSummary(
            totalSeconds: totalSeconds,
            topLanguage: topLanguage,
            topProject: topProject,
            editorUsage: editorUsage
        )
    }

    private static func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
