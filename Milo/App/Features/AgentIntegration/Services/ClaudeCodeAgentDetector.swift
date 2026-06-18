//
//  ClaudeCodeAgentDetector.swift
//  Milo
//
//  PRIVACY: Only checks process names and command keywords.
//  Does not read prompts, output, or source code.
//

import Foundation

struct ClaudeCodeAgentDetector: MiloAgentDetectorProtocol {
    let agentType: MiloAgentType = .claudeCode

    func detect(
        from processes: [MiloAgentProcessSnapshot],
        previous event: MiloAgentEvent?
    ) -> MiloAgentEvent? {
        let matches = processes.filter { process in
            let name = process.processName.lowercased()
            let command = process.command?.lowercased() ?? ""
            return name.contains("claude") || command.contains("claude") || command.contains("claude-code")
        }
        guard !matches.isEmpty else { return nil }
        return MiloAgentEvent(
            agentType: .claudeCode,
            state: .running,
            title: "Claude Code running",
            detail: "MILO detected an active Claude Code task.",
            startedAt: event?.startedAt ?? Date()
        )
    }
}
