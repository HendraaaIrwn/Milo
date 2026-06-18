//
//  CodexHookSnippetBuilder.swift
//  Milo
//

import Foundation

enum CodexHookSnippetBuilder {
    static func build(miloctlPath: String) -> String {
        let events: [(name: String, matcher: String?, status: String)] = [
            ("SessionStart", nil, "Notifying MILO"),
            ("UserPromptSubmit", nil, "MILO noticed your prompt"),
            ("PreToolUse", ".*", "MILO sees Codex working"),
            ("PermissionRequest", ".*", "MILO sees Codex needs approval"),
            ("PostToolUse", ".*", "MILO saw Codex finish a tool"),
            ("SubagentStart", nil, "MILO sees a helper start"),
            ("SubagentStop", nil, "MILO sees a helper finish"),
            ("PreCompact", nil, "MILO sees Codex compacting"),
            ("PostCompact", nil, "MILO sees Codex compacting"),
            ("Stop", nil, "MILO sees Codex finish")
        ]

        var hooksObject: [String: Any] = [:]
        for event in events {
            var item: [String: Any] = [
                "hooks": [[
                    "type": "command",
                    "command": "\(miloctlPath) codex-event --event \(event.name)",
                    "timeout": 5,
                    "statusMessage": event.status
                ]]
            ]
            if let matcher = event.matcher {
                item["matcher"] = matcher
            }
            hooksObject[event.name] = [item]
        }

        let root: [String: Any] = ["hooks": hooksObject]
        guard let data = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}
