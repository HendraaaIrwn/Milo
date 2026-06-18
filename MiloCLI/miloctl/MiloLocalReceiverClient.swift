//
//  MiloLocalReceiverClient.swift
//  miloctl
//
//  PRIVACY: Reads the receiver config from the user's Application Support
//  directory and POSTs a sanitized UnifiedAgentHookEvent. Never sends raw
//  stdin, never logs the event payload, never writes to disk.
//

import Foundation

struct MiloLocalAgentEventReceiverConfig: Codable, Equatable {
    var host: String
    var port: Int
    var token: String
}

enum MiloLocalReceiverClientError: Error {
    case configMissing
    case configInvalid
    case transportError(String)
    case badStatus(Int)
}

struct MiloLocalReceiverClient {
    let config: MiloLocalAgentEventReceiverConfig
    let timeout: TimeInterval

    init(config: MiloLocalAgentEventReceiverConfig, timeout: TimeInterval = 2.0) {
        self.config = config
        self.timeout = timeout
    }

    static func loadConfig() throws -> MiloLocalAgentEventReceiverConfig {
        let support = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first
        guard let support else { throw MiloLocalReceiverClientError.configMissing }
        let url = support
            .appendingPathComponent("MILO", isDirectory: true)
            .appendingPathComponent("agent-receiver.json")
        guard let data = try? Data(contentsOf: url) else {
            throw MiloLocalReceiverClientError.configMissing
        }
        do {
            return try JSONDecoder().decode(MiloLocalAgentEventReceiverConfig.self, from: data)
        } catch {
            throw MiloLocalReceiverClientError.configInvalid
        }
    }

    func send(_ event: UnifiedAgentHookEvent) async throws {
        let host = config.host
        let port = config.port
        guard let url = URL(string: "http://\(host):\(port)/agent-event") else {
            throw MiloLocalReceiverClientError.configInvalid
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(event)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw MiloLocalReceiverClientError.transportError("no http response")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw MiloLocalReceiverClientError.badStatus(http.statusCode)
            }
        } catch let err as MiloLocalReceiverClientError {
            throw err
        } catch let urlError as URLError {
            throw MiloLocalReceiverClientError.transportError(urlError.localizedDescription)
        } catch {
            throw MiloLocalReceiverClientError.transportError(error.localizedDescription)
        }
    }
}
