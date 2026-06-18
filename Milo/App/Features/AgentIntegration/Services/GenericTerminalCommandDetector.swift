//
//  GenericTerminalCommandDetector.swift
//  Milo
//
//  PRIVACY: Detects common build/task commands by process name only.
//  Does not read command output, arguments, or terminal content.
//  OFF by default — user must opt in via settings.
//

import Foundation

struct GenericTerminalCommandDetector: MiloAgentDetectorProtocol {
    let agentType: MiloAgentType = .genericTerminal

    private let keywords = [
        "npm", "pnpm", "bun",
        "node", "python",
        "swift",
        "make", "gradle", "cargo", "go"
    ]

    func detect(
        from processes: [MiloAgentProcessSnapshot],
        previous event: MiloAgentEvent?
    ) -> MiloAgentEvent? {
        let matches = processes.filter { process in
            let name = process.processName.lowercased()
            let command = process.command?.lowercased() ?? ""
            return keywords.contains { keyword in
                name == keyword || command.contains(keyword)
            }
        }
        guard !matches.isEmpty else { return nil }
        return MiloAgentEvent(
            agentType: .genericTerminal,
            state: .running,
            title: "Command running",
            detail: "MILO detected a long-running terminal task.",
            startedAt: event?.startedAt ?? Date()
        )
    }
}
