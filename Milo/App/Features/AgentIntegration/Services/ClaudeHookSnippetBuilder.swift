//
//  ClaudeHookSnippetBuilder.swift
//  Milo
//
//  Builds the JSON snippet the user pastes into their Claude Code
//  settings (~/.claude/settings.json) to wire up hooks.
//

import Foundation

enum ClaudeHookSnippetBuilder {
    /// Generates a JSON snippet using the given `miloctl` executable path.
    /// The user is expected to merge this into their Claude Code settings
    /// manually — MILO does not edit Claude settings on the user's behalf.
    static func build(miloctlPath: String) -> String {
        let events: [String] = [
            "SessionStart", "SessionEnd",
            "UserPromptSubmit", "PreToolUse", "PermissionRequest", "PostToolUse",
            "Notification", "Stop", "StopFailure",
            "SubagentStart", "SubagentStop",
            "PreCompact"
        ]

        var hooksObject: [String: Any] = [:]
        for event in events {
            hooksObject[event] = [[
                "matcher": "",
                "hooks": [[
                    "type": "command",
                    "command": "\(miloctlPath) claude-event --event \(event)"
                ]]
            ]]
        }

        let root: [String: Any] = ["hooks": hooksObject]

        guard let data = try? JSONSerialization.data(
            withJSONObject: root,
            options: [.prettyPrinted, .sortedKeys]
        ),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}
