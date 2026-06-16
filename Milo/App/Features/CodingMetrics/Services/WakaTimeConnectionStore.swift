//
//  WakaTimeConnectionStore.swift
//  Milo
//
//  PRIVACY: WakaTime API key is stored in macOS Keychain.
//  MILO never logs or displays the full API key.
//  Local coding metrics continue to work without WakaTime.
//  Local metrics are not uploaded to WakaTime.
//

import Combine
import Foundation

@MainActor
final class WakaTimeConnectionStore: ObservableObject {
    static let shared = WakaTimeConnectionStore(client: WakaTimeClient())

    @Published var apiKeyInput: String = ""
    @Published private(set) var status: WakaTimeConnectionStatus = .notConnected
    @Published private(set) var lastTestedAt: Date?
    @Published private(set) var hasSavedAPIKey: Bool = false
    @Published private(set) var isTesting: Bool = false

    // Debug state (not persisted)
    @Published private(set) var savedKeyLength: Int = 0
    @Published private(set) var lastEndpoint: String = ""
    @Published private(set) var lastHTTPStatus: Int?
    @Published private(set) var lastErrorBody: String?

    private let client: WakaTimeClient

    init(client: WakaTimeClient) {
        self.client = client
        refreshSavedKeyState()
        self.lastTestedAt = UserDefaults.standard.object(
            forKey: MiloStorageKeys.wakaTimeLastTestedAt
        ) as? Date
    }

    func refreshSavedKeyState() {
        hasSavedAPIKey = client.hasAPIKey()
        if hasSavedAPIKey {
            savedKeyLength = client.debugKeychainState().contains("Length:")
                ? Int(client.debugKeychainState().split(separator: ":").last?.trimmingCharacters(in: .whitespaces) ?? "0") ?? 0
                : 0
        } else {
            savedKeyLength = 0
            status = .notConnected
        }
    }

    func saveAndTest() {
        Task { await saveAndTestAsync() }
    }

    func testConnection() {
        Task { await testConnectionAsync() }
    }

    func disconnect() {
        client.deleteAPIKey()
        UserDefaults.standard.set(false, forKey: MiloStorageKeys.wakaTimeEnabled)
        UserDefaults.standard.removeObject(forKey: MiloStorageKeys.wakaTimeLastTestedAt)
        UserDefaults.standard.removeObject(forKey: MiloStorageKeys.wakaTimeLastConnectedUsername)
        UserDefaults.standard.removeObject(forKey: MiloStorageKeys.wakaTimeLastConnectedEmail)
        apiKeyInput = ""
        hasSavedAPIKey = false
        savedKeyLength = 0
        lastTestedAt = nil
        lastHTTPStatus = nil
        lastErrorBody = nil
        lastEndpoint = ""
        status = .notConnected
    }

    func autoTestIfKeyExists() {
        guard hasSavedAPIKey else { return }
        Task { await testConnectionAsync() }
    }

    private func saveAndTestAsync() async {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            status = .unknownError(message: "Please enter your WakaTime API key first.")
            return
        }

        do {
            try client.saveAPIKey(trimmed)
            apiKeyInput = ""
            hasSavedAPIKey = true
            savedKeyLength = trimmed.count
            lastEndpoint = WakaTimeClient.currentUserEndpoint
            await testConnectionAsync()
        } catch {
            status = .unknownError(message: "Could not save API key to Keychain. \(error.localizedDescription)")
        }
    }

    private func testConnectionAsync() async {
        guard !isTesting else { return }

        isTesting = true
        status = .checking
        lastHTTPStatus = nil
        lastErrorBody = nil
        lastEndpoint = WakaTimeClient.currentUserEndpoint

        let result = await client.testConnection()

        status = result
        isTesting = false

        let now = Date()
        lastTestedAt = now
        UserDefaults.standard.set(now, forKey: MiloStorageKeys.wakaTimeLastTestedAt)

        lastErrorBody = result.detailString
        refreshSavedKeyState()

        if case .connected(let profile) = result {
            UserDefaults.standard.set(true, forKey: MiloStorageKeys.wakaTimeEnabled)
            UserDefaults.standard.set(profile.username, forKey: MiloStorageKeys.wakaTimeLastConnectedUsername)
            UserDefaults.standard.set(profile.email, forKey: MiloStorageKeys.wakaTimeLastConnectedEmail)
            lastHTTPStatus = 200
        } else {
            UserDefaults.standard.set(false, forKey: MiloStorageKeys.wakaTimeEnabled)
        }
    }

    var lastHTTPStatusDescription: String {
        guard let code = lastHTTPStatus else { return "-" }
        return "\(code)"
    }

    var keychainDebug: String {
        client.debugKeychainState()
    }
}
