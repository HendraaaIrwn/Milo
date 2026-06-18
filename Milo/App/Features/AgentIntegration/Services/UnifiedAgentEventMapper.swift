//
//  UnifiedAgentEventMapper.swift
//  Milo
//

import Foundation

struct UnifiedAgentEventMapper {
    func agentState(for event: UnifiedAgentHookEvent) -> MiloAgentState {
        switch event.normalizedEvent {
        case .sessionStarted, .promptSubmitted, .thinking, .toolStarted,
             .toolFinished, .subtaskStarted, .compacting, .unknown:
            return .running
        case .permissionRequested, .waitingForInput:
            return .waitingForUserInput
        case .taskFinished, .subtaskFinished, .sessionEnded:
            return .done
        case .taskFailed:
            return .failed
        }
    }

    func badgeLabel(for event: UnifiedAgentHookEvent) -> String {
        let agent = displayName(for: event.agentType)
        switch event.normalizedEvent {
        case .sessionStarted:       return "\(agent) session"
        case .promptSubmitted:      return "\(agent) thinking"
        case .thinking:             return "\(agent) thinking"
        case .toolStarted:          return "\(agent) working"
        case .toolFinished:         return "\(agent) worked"
        case .permissionRequested:  return "\(agent) permission"
        case .waitingForInput:      return "\(agent) waiting"
        case .taskFinished:         return "\(agent) done"
        case .taskFailed:           return "\(agent) failed"
        case .subtaskStarted:       return "\(agent) helper"
        case .subtaskFinished:      return "Helper done"
        case .compacting:           return "\(agent) compacting"
        case .sessionEnded:         return "\(agent) ended"
        case .unknown:              return "\(agent) event"
        }
    }

    func title(for event: UnifiedAgentHookEvent) -> String {
        let agent = displayName(for: event.agentType)
        switch event.normalizedEvent {
        case .sessionStarted:       return "\(agent) session started"
        case .promptSubmitted:      return "\(agent) received a prompt"
        case .thinking:             return "\(agent) is thinking"
        case .toolStarted:          return "\(agent) tool started"
        case .toolFinished:         return "\(agent) tool finished"
        case .permissionRequested:  return "\(agent) needs permission"
        case .waitingForInput:      return "\(agent) needs input"
        case .taskFinished:         return "\(agent) finished"
        case .taskFailed:           return "\(agent) failed"
        case .subtaskStarted:       return "\(agent) subtask started"
        case .subtaskFinished:      return "\(agent) subtask finished"
        case .compacting:           return "\(agent) compacting"
        case .sessionEnded:         return "\(agent) session ended"
        case .unknown:              return "\(agent) event"
        }
    }

    func bubbleText(for event: UnifiedAgentHookEvent) -> String {
        let agent = displayName(for: event.agentType)
        switch event.normalizedEvent {
        case .sessionStarted:
            return "\(agent) session started. Tiny watch mode on."
        case .promptSubmitted:
            return "\(agent) received a prompt. MILO is watching the sparks."
        case .thinking:
            return "\(agent) is thinking. Tiny gears spinning."
        case .toolStarted:
            if let tool = event.toolName { return "\(agent) is using \(tool)." }
            return "\(agent) is using a tool."
        case .toolFinished:
            if let tool = event.toolName { return "\(agent) finished \(tool)." }
            return "\(agent) finished a tool step."
        case .permissionRequested:
            return "\(agent) needs permission. Tiny approval bell."
        case .waitingForInput:
            return "\(agent) needs your input."
        case .taskFinished:
            return "\(agent) finished. Tiny victory detected."
        case .taskFailed:
            return "\(agent) hit an error. Tiny drama detected."
        case .subtaskStarted:
            return "\(agent) spun up a tiny helper."
        case .subtaskFinished:
            return "\(agent)’s helper finished."
        case .compacting:
            return "\(agent) is compacting context. Tiny brain cleanup."
        case .sessionEnded:
            return "\(agent) session ended. MILO stands down."
        case .unknown:
            return "\(agent) sent an event. MILO noticed."
        }
    }

    func priority(for event: UnifiedAgentHookEvent) -> MiloBubblePriority {
        switch event.normalizedEvent {
        case .permissionRequested, .waitingForInput, .taskFinished, .taskFailed, .sessionEnded:
            return .high
        case .promptSubmitted, .toolStarted, .toolFinished, .sessionStarted, .subtaskStarted, .subtaskFinished:
            return .normal
        case .thinking, .compacting, .unknown:
            return .low
        }
    }

    func companionMood(for event: UnifiedAgentHookEvent) -> MiloMood {
        switch event.normalizedEvent {
        case .permissionRequested, .waitingForInput:
            return .confused
        case .taskFinished, .sessionEnded, .subtaskFinished:
            return .happy
        case .taskFailed:
            return .confused
        case .sessionStarted, .promptSubmitted, .thinking, .toolStarted, .toolFinished, .subtaskStarted, .compacting:
            return .focus
        case .unknown:
            return .idle
        }
    }

    private func displayName(for agent: MiloAgentType) -> String {
        switch agent {
        case .codex:           return "Codex"
        case .claudeCode:      return "Claude"
        case .cursorAgent:     return "Cursor"
        case .xcodeBuild:      return "Xcode"
        case .genericTerminal: return "Terminal"
        case .unknown:         return "Agent"
        }
    }
}
