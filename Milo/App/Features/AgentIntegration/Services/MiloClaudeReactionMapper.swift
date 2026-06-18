//
//  MiloClaudeReactionMapper.swift
//  Milo
//
//  Pure mapping from a sanitized Claude hook event to the agent-state
//  model, badge copy, bubble copy, priority, and companion mood.
//  This file is the single source of truth for the per-event reactions
//  listed in the hooks integration spec — keep the table in sync.
//

import Foundation

struct MiloClaudeReactionMapper {
    func agentState(for event: MiloClaudeHookEvent) -> MiloAgentState {
        switch event.eventName {
        case .sessionStart, .userPromptSubmit, .preToolUse, .postToolUse,
             .subagentStart, .preCompact, .unknown:
            return .running
        case .notification:
            return .waitingForUserInput
        case .stop, .sessionEnd, .subagentStop:
            return .done
        }
    }

    func title(for event: MiloClaudeHookEvent) -> String {
        switch event.eventName {
        case .sessionStart:      return "Claude session started"
        case .sessionEnd:        return "Claude session ended"
        case .userPromptSubmit:  return "Claude received a task"
        case .preToolUse:        return "Claude tool running"
        case .postToolUse:       return "Claude tool finished"
        case .notification:      return "Claude needs input"
        case .stop:              return "Claude finished"
        case .subagentStart:     return "Claude subagent started"
        case .subagentStop:      return "Claude subagent finished"
        case .preCompact:        return "Claude compacting context"
        case .unknown:           return "Claude event"
        }
    }

    func detail(for event: MiloClaudeHookEvent) -> String? {
        if let toolName = event.toolName,
           event.eventName == .preToolUse || event.eventName == .postToolUse {
            return "Tool: \(toolName)"
        }

        return nil
    }

    func bubbleText(for event: MiloClaudeHookEvent) -> String? {
        switch event.eventName {
        case .sessionStart:
            return "Claude session started. Tiny watch mode on."

        case .sessionEnd:
            return "Claude session ended. MILO stands down."

        case .userPromptSubmit:
            return "Claude received a task. MILO is watching the sparks."

        case .preToolUse:
            if let tool = event.toolName {
                return "Claude is using \(tool)."
            }
            return "Claude is using a tool."

        case .postToolUse:
            if let tool = event.toolName {
                return "Claude finished \(tool)."
            }
            return "Claude finished a tool step."

        case .notification:
            return "Claude needs your input."

        case .stop:
            return "Claude finished. Tiny victory detected."

        case .subagentStart:
            return "Claude spun up a tiny helper."

        case .subagentStop:
            return "Claude’s helper finished."

        case .preCompact:
            return "Claude is compacting context. Tiny brain cleanup."

        case .unknown:
            return "Claude sent an event. MILO noticed."
        }
    }

    func priority(for event: MiloClaudeHookEvent) -> MiloBubblePriority {
        switch event.eventName {
        case .notification, .stop, .sessionEnd:
            return .high
        case .preToolUse, .postToolUse, .userPromptSubmit, .sessionStart,
             .subagentStart, .subagentStop:
            return .normal
        case .preCompact, .unknown:
            return .low
        }
    }

    /// Maps to the existing MiloMood cases. We do not introduce new moods.
    func companionMood(for event: MiloClaudeHookEvent) -> MiloMood {
        switch event.eventName {
        case .notification:
            return .confused   // "curious tilt"
        case .stop, .sessionEnd, .subagentStop:
            return .happy
        case .preToolUse, .postToolUse, .userPromptSubmit,
             .sessionStart, .subagentStart, .preCompact:
            return .focus      // "thinking face"
        case .unknown:
            return .idle
        }
    }
}