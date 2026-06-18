//
//  ClaudeHookEventName.swift
//  Milo
//
//  PRIVACY: Maps Claude Code hook event names to a closed enum.
//  Any unknown event falls back to .unknown — never crashes and never
//  carries the original raw name into the rest of the app.
//

import Foundation

enum ClaudeHookEventName: String, Codable, Equatable {
    case sessionStart = "SessionStart"
    case sessionEnd = "SessionEnd"
    case userPromptSubmit = "UserPromptSubmit"
    case preToolUse = "PreToolUse"
    case postToolUse = "PostToolUse"
    case notification = "Notification"
    case stop = "Stop"
    case subagentStart = "SubagentStart"
    case subagentStop = "SubagentStop"
    case preCompact = "PreCompact"
    case unknown = "Unknown"

    init(raw: String) {
        self = ClaudeHookEventName(rawValue: raw) ?? .unknown
    }
}
