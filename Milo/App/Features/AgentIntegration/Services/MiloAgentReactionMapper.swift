//
//  MiloAgentReactionMapper.swift
//  Milo
//

import Foundation

struct MiloAgentReactionMapper {
    func bubbleText(for event: MiloAgentEvent) -> String? {
        switch event.agentType {
        case .xcodeBuild:
            return xcodeBuildBubbleText(for: event)
        default:
            return defaultBubbleText(for: event)
        }
    }

    func companionMood(for state: MiloAgentState) -> MiloMood {
        switch state {
        case .idle:       return .idle
        case .thinking:   return .focus
        case .running:    return .focus
        case .waitingForUserInput: return .confused
        case .done:       return .happy
        case .failed:     return .confused
        case .needsReview: return .focus
        }
    }

    private func xcodeBuildBubbleText(for event: MiloAgentEvent) -> String? {
        switch event.state {
        case .running:                   return nil
        case .done:                      return "Xcode build finished. Tiny hammer rests."
        case .failed:                    return "Xcode build failed. Tiny drama detected."
        case .needsReview:               return "Build changes may need review."
        case .waitingForUserInput:       return "Xcode may need your attention."
        case .thinking:                  return "Xcode is preparing the tiny forge."
        case .idle:                      return nil
        }
    }

    private func defaultBubbleText(for event: MiloAgentEvent) -> String? {
        switch event.state {
        case .idle, .thinking, .running: return nil
        case .waitingForUserInput:       return "\(event.agentType.displayName) needs your input."
        case .done:                      return "\(event.agentType.displayName) finished. Tiny victory."
        case .failed:                    return "\(event.agentType.displayName) failed. Tiny drama detected."
        case .needsReview:               return "Changes are ready for review."
        }
    }
}
