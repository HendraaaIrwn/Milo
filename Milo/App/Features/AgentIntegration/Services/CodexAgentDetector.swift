//
//  CodexAgentDetector.swift
//  Milo
//
//  PRIVACY: Only checks process names and command keywords.
//  Does not read prompts, output, or source code.
//

import Foundation

struct CodexAgentDetector: MiloAgentDetectorProtocol {
    let agentType: MiloAgentType = .codex

    func detect(
        from processes: [MiloAgentProcessSnapshot],
        previous event: MiloAgentEvent?
    ) -> MiloAgentEvent? {
        let matches = processes.filter { process in
            let name = process.processName.lowercased()
            let command = process.command?.lowercased() ?? ""
            return name.contains("codex") || command.contains("codex") || command.contains("openai")
        }
        guard !matches.isEmpty else { return nil }
        return MiloAgentEvent(
            agentType: .codex,
            state: .running,
            title: "Codex running",
            detail: "MILO detected an active Codex task.",
            startedAt: event?.startedAt ?? Date()
        )
    }
}
