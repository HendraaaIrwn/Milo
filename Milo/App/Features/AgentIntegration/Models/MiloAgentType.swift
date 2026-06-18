//
//  MiloAgentType.swift
//  Milo
//

import Foundation

enum MiloAgentType: String, Codable, CaseIterable, Identifiable {
    case codex
    case claudeCode
    case cursorAgent
    case xcodeBuild
    case genericTerminal
    case unknown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .codex:             return "Codex"
        case .claudeCode:        return "Claude Code"
        case .cursorAgent:       return "Cursor Agent"
        case .xcodeBuild:        return "Xcode Build"
        case .genericTerminal:   return "Terminal Command"
        case .unknown:           return "Unknown Agent"
        }
    }

    var symbolName: String {
        switch self {
        case .codex:             return "terminal"
        case .claudeCode:        return "sparkles"
        case .cursorAgent:       return "cursorarrow"
        case .xcodeBuild:        return "hammer"
        case .genericTerminal:   return "apple.terminal"
        case .unknown:           return "questionmark.circle"
        }
    }
}
