//
//  UnifiedAgentHookPayloadSanitizer.swift
//  Milo
//
//  PRIVACY: Allowlist-only sanitizer for hook JSON. Drops prompts,
//  responses, tool input/output, source code, logs, full paths,
//  clipboard contents, passwords, API keys, secrets, and raw JSON.
//

import Foundation
import CryptoKit

struct UnifiedAgentHookPayloadSanitizer {
    func sanitize(
        agentType: MiloAgentType,
        rawEventName: String?,
        stdinData: Data
    ) -> UnifiedAgentHookEvent {
        let json = parseJSON(stdinData)
        let inferredEvent = rawEventName
            ?? json["hook_event_name"] as? String
            ?? json["event"] as? String
            ?? json["hook_event"] as? String
            ?? "Unknown"

        let sessionID = json["session_id"] as? String
            ?? json["sessionId"] as? String
            ?? json["turn_id"] as? String

        let cwd = json["cwd"] as? String
            ?? json["workspace"] as? String

        return UnifiedAgentHookEvent(
            agentType: agentType,
            eventName: sanitizeEventName(inferredEvent),
            normalizedEvent: normalize(agentType: agentType, eventName: inferredEvent),
            sessionHash: sessionID.map(hash),
            workspaceName: cwd.map { URL(fileURLWithPath: $0).lastPathComponent },
            toolName: extractToolName(from: json),
            deliveryMethod: .hookCommand
        )
    }

    private func normalize(agentType: MiloAgentType, eventName: String) -> UnifiedAgentEventKind {
        switch eventName.lowercased() {
        case "sessionstart":      return .sessionStarted
        case "sessionend":        return agentType == .claudeCode ? .sessionEnded : .unknown
        case "userpromptsubmit":  return .promptSubmitted
        case "pretooluse":        return .toolStarted
        case "posttooluse":       return .toolFinished
        case "permissionrequest": return .permissionRequested
        case "notification":      return agentType == .claudeCode ? .waitingForInput : .unknown
        case "stop":              return .taskFinished
        case "stopfailure":       return agentType == .claudeCode ? .taskFailed : .unknown
        case "subagentstart":     return .subtaskStarted
        case "subagentstop":      return .subtaskFinished
        case "precompact", "postcompact": return .compacting
        default:                   return .unknown
        }
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

    private func sanitizeEventName(_ value: String) -> String {
        let trimmed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Unknown" }
        return String(trimmed.prefix(64))
    }

    private func sanitizeToolName(_ value: String) -> String? {
        let trimmed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let basename = URL(fileURLWithPath: trimmed).lastPathComponent
        let safe = basename.isEmpty ? trimmed : basename
        guard !safe.isEmpty else { return nil }
        return String(safe.prefix(64))
    }

    private func hash(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
    }
}
