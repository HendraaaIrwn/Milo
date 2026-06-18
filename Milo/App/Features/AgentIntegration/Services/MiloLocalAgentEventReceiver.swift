//
//  MiloLocalAgentEventReceiver.swift
//  Milo
//
//  PRIVACY: Localhost-only HTTP receiver for sanitized agent hook events. Binds to 127.0.0.1, never to 0.0.0.0 or any external
//  interface. Authenticated with a Bearer token generated locally
//  and stored in the user's Application Support directory.
//
//  The receiver parses a minimal HTTP/1.1 request itself (POST only,
//  small body cap) and never logs the request body. The decoded
//  UnifiedAgentHookEvent is forwarded to the handler on MainActor.
//

import Foundation
import Network
import OSLog

@MainActor
final class MiloLocalAgentEventReceiver {
    private let logger = Logger(
        subsystem: "com.milo",
        category: "AgentReceiver"
    )

    private var listener: NWListener?
    private var connections: [ObjectIdentifier: NWConnection] = [:]
    private let queue = DispatchQueue(label: "com.milo.claudeReceiver", qos: .utility)

    private let handler: (UnifiedAgentHookEvent) -> Void
    private let onStateChange: (Bool) -> Void
    private let onConfigUpdate: (MiloLocalAgentEventReceiverConfig) -> Void

    private(set) var config: MiloLocalAgentEventReceiverConfig
    private(set) var isRunning: Bool = false

    private let maxBodyBytes = 64 * 1024 // 64 KiB cap on the request body
    private let requestTimeoutSeconds: TimeInterval = 5

    init(
        config: MiloLocalAgentEventReceiverConfig,
        handler: @escaping (UnifiedAgentHookEvent) -> Void,
        onStateChange: @escaping (Bool) -> Void = { _ in },
        onConfigUpdate: @escaping (MiloLocalAgentEventReceiverConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.handler = handler
        self.onStateChange = onStateChange
        self.onConfigUpdate = onConfigUpdate
    }

    func start() {
        guard !isRunning else { return }
        guard let port = NWEndpoint.Port(rawValue: config.port) else {
            logger.error("Agent receiver: invalid port \(self.config.port)")
            return
        }

        do {
            let parameters = NWParameters.tcp
            parameters.acceptLocalOnly = true
            parameters.allowLocalEndpointReuse = true
            // Restrict to loopback interface only.
            if let loopback = NWInterface.InterfaceType.loopback as NWInterface.InterfaceType? {
                parameters.requiredInterfaceType = .loopback
            }

            let listener = try NWListener(using: parameters, on: port)
            listener.newConnectionHandler = { [weak self] connection in
                self?.accept(connection)
            }
            listener.stateUpdateHandler = { [weak self] (state: NWListener.State) in
                guard let self else { return }
                Task { @MainActor in
                    self.handleListenerState(state)
                }
            }
            listener.start(queue: queue)
            self.listener = listener
        } catch {
            logger.error("Agent receiver failed to start: \(error.localizedDescription)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
        for (_, connection) in connections {
            connection.cancel()
        }
        connections.removeAll()
        isRunning = false
        onStateChange(false)
    }

    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            isRunning = true
            onStateChange(true)
            logger.info("Agent receiver listening on \(self.config.host, privacy: .public):\(self.config.port)")
        case .failed(let error):
            isRunning = false
            onStateChange(false)
            logger.error("Agent receiver failed: \(error.localizedDescription)")
        case .cancelled:
            isRunning = false
            onStateChange(false)
        default:
            break
        }
    }

    nonisolated private func accept(_ connection: NWConnection) {
        let id = ObjectIdentifier(connection)
        Task { @MainActor [weak self] in
            self?.connections[id] = connection
        }
        connection.stateUpdateHandler = { [weak self] (state: NWConnection.State) in
            guard let self else { return }
            if case .cancelled = state {
                Task { @MainActor in
                    self.connections.removeValue(forKey: id)
                }
            } else if case .failed = state {
                Task { @MainActor in
                    self.connections.removeValue(forKey: id)
                }
            }
        }
        receiveRequest(connection: connection, accumulator: Data())
        connection.start(queue: queue)
    }

    nonisolated private func receiveRequest(connection: NWConnection, accumulator: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 16 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }

            if let error = error {
                self.logger.error("Agent receiver connection error: \(error.localizedDescription)")
                connection.cancel()
                return
            }

            var accumulated = accumulator
            if let data, !data.isEmpty {
                accumulated.append(data)
            }

            if accumulated.count > self.maxBodyBytes {
                Task { @MainActor [weak self] in
                    self?.respondBadRequest(connection: connection, reason: "Body too large")
                    connection.cancel()
                }
                return
            }

            if let parsed = Self.parseRequest(accumulated) {
                Task { @MainActor [weak self] in
                    self?.handleParsedRequest(parsed, connection: connection)
                }
                return
            }

            if isComplete {
                Task { @MainActor [weak self] in
                    self?.respondBadRequest(connection: connection, reason: "Incomplete request")
                    connection.cancel()
                }
                return
            }

            self.receiveRequest(connection: connection, accumulator: accumulated)
        }
    }

    private struct ParsedRequest {
        let method: String
        let path: String
        let headers: [String: String]
        let body: Data
    }

    nonisolated private static func parseRequest(_ data: Data) -> ParsedRequest? {
        guard let raw = String(data: data, encoding: .utf8) else { return nil }

        // HTTP request line + headers + body are separated by CRLFCRLF.
        let headerTerminator = "\r\n\r\n"
        guard let headerRange = raw.range(of: headerTerminator) else {
            return nil
        }

        let headerSection = String(raw[..<headerRange.lowerBound])
        let bodyString = String(raw[headerRange.upperBound...])
        let bodyData = bodyString.data(using: .utf8) ?? Data()

        let lines = headerSection.split(separator: "\r\n")
        guard let requestLine = lines.first else { return nil }

        let requestParts = requestLine.split(separator: " ", maxSplits: 2).map(String.init)
        guard requestParts.count >= 2 else { return nil }
        let method = requestParts[0]
        let path = requestParts[1]

        var headers: [String: String] = [:]
        for headerLine in lines.dropFirst() {
            guard let colon = headerLine.firstIndex(of: ":") else { continue }
            let name = String(headerLine[..<colon]).lowercased().trimmingCharacters(in: .whitespaces)
            let value = String(headerLine[headerLine.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
            headers[name] = value
        }

        return ParsedRequest(method: method, path: path, headers: headers, body: bodyData)
    }

    private func handleParsedRequest(_ request: ParsedRequest, connection: NWConnection) {
        guard request.method == "POST" else {
            respondBadRequest(connection: connection, reason: "Method not allowed")
            connection.cancel()
            return
        }

        guard Self.authorize(headers: request.headers, expectedToken: config.token) else {
            respondUnauthorized(connection: connection)
            connection.cancel()
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let event: UnifiedAgentHookEvent
        do {
            event = try decoder.decode(UnifiedAgentHookEvent.self, from: request.body)
        } catch {
            logger.error("Agent receiver decode error: \(error.localizedDescription)")
            respondBadRequest(connection: connection, reason: "Invalid payload")
            connection.cancel()
            return
        }

        // The receiver only stores the decoded event in-memory long enough
        // to forward to the handler. It does not log the body.
        handler(event)
        respondOK(connection: connection)
        connection.cancel()
    }

    nonisolated private static func authorize(headers: [String: String], expectedToken: String) -> Bool {
        guard let header = headers["authorization"] else { return false }
        let prefix = "Bearer "
        guard header.hasPrefix(prefix) else { return false }
        let token = String(header.dropFirst(prefix.count))
        return token == expectedToken
    }

    private func respondOK(connection: NWConnection) {
        sendResponse(connection: connection, status: "200 OK", body: Data("{\"ok\":true}".utf8))
    }

    private func respondBadRequest(connection: NWConnection, reason: String) {
        let body = "{\"ok\":false,\"reason\":\(Self.jsonString(reason))}"
        sendResponse(connection: connection, status: "400 Bad Request", body: Data(body.utf8))
    }

    private func respondUnauthorized(connection: NWConnection) {
        let body = "{\"ok\":false,\"reason\":\"unauthorized\"}"
        sendResponse(connection: connection, status: "401 Unauthorized", body: Data(body.utf8))
    }

    private func sendResponse(connection: NWConnection, status: String, body: Data) {
        let headers = [
            "HTTP/1.1 \(status)",
            "Content-Type: application/json",
            "Content-Length: \(body.count)",
            "Connection: close",
            ""
        ].joined(separator: "\r\n")
        var payload = Data(headers.utf8)
        payload.append(Data("\r\n".utf8))
        payload.append(body)

        connection.send(content: payload, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private static func jsonString(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
