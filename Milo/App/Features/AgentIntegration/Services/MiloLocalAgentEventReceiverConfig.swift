//
//  MiloLocalAgentEventReceiverConfig.swift
//  Milo
//
//  Persists the localhost binding for the agent hook receiver.
//  Stored at ~/Library/Application Support/MILO/agent-receiver.json via
//  MiloLocalStorageService. The token is a 32-byte random hex string and
//  is generated on first receiver start — it is never logged.
//

import Foundation

struct MiloLocalAgentEventReceiverConfig: Codable, Equatable {
    var host: String
    var port: UInt16
    var token: String

    static let defaultHost = "127.0.0.1"
    static let defaultPort: UInt16 = 47321

    static func makeDefault() -> MiloLocalAgentEventReceiverConfig {
        MiloLocalAgentEventReceiverConfig(
            host: defaultHost,
            port: defaultPort,
            token: Self.generateToken()
        )
    }

    static func generateToken() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if result == errSecSuccess {
            return bytes.map { String(format: "%02x", $0) }.joined()
        }
        // Fallback if SecRandom is unavailable (shouldn't happen on macOS):
        // timestamp-based token. Still unguessable in practice for localhost.
        let now = UInt64(Date().timeIntervalSince1970 * 1_000_000)
        return String(now, radix: 16) + UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
