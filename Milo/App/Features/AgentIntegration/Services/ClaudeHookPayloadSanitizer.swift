//
//  ClaudeHookPayloadSanitizer.swift
//  Milo
//
//  PRIVACY: This is the single funnel that converts a raw Claude Code
//  hook payload (delivered via stdin to `miloctl`) into a safe
//  MiloClaudeHookEvent. It has an explicit allowlist of fields. Anything
//  not on the allowlist is dropped — including prompts, responses, tool
//  input, tool output, full file paths, and arbitrary extra keys.
//
//  This file is intentionally duplicated as a near-copy inside the
//  `miloctl` CLI target so the CLI does not need to import the app
//  module. Keep the two copies in sync: same allowlist, same hash,
//  same basename rule, same default behavior.
//

import Foundation
import CryptoKit

struct ClaudeHookPayloadSanitizer {
    func sanitize(
        rawEventName: String?,
        stdinData: Data
    ) -> MiloClaudeHookEvent {
        let json = parseJSON(stdinData)

        let inferredEvent = rawEventName
            ?? json["hook_event_name"] as? String
            ?? json["event"] as? String
            ?? "Unknown"

        let eventName = ClaudeHookEventName(raw: inferredEvent)

        let sessionID = json["session_id"] as? String
        let sessionHash = sessionID.map(hash)

        let cwd = json["cwd"] as? String
        let workspaceName = cwd.map { URL(fileURLWithPath: $0).lastPathComponent }

        let toolName = extractToolName(from: json)

        return MiloClaudeHookEvent(
            eventName: eventName,
            rawEventName: inferredEvent,
            sessionHash: sessionHash,
            workspaceName: workspaceName,
            toolName: toolName,
            deliveryMethod: .hookCommand
        )
    }

    private func parseJSON(_ data: Data) -> [String: Any] {
        guard !data.isEmpty,
              let object = try? JSONSerialization.jsonObject(with: data),
              let dict = object as? [String: Any] else {
            return [:]
        }

        return dict
    }

    private func extractToolName(from json: [String: Any]) -> String? {
        if let toolName = json["tool_name"] as? String {
            return sanitizeToolName(toolName)
        }

        if let tool = json["tool"] as? [String: Any],
           let name = tool["name"] as? String {
            return sanitizeToolName(name)
        }

        return nil
    }

    private func sanitizeToolName(_ value: String) -> String? {
        let trimmed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return nil }

        // Tool names should be short identifiers. Defensively cap the
        // length to avoid any accidental content from being passed through.
        return String(trimmed.prefix(64))
    }

    private func hash(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
    }
}
