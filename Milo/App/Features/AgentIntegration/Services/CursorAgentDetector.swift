//
//  CursorAgentDetector.swift
//  Milo
//
//  PRIVACY: Only checks process names for Cursor Agent activity.
//  Conservative detection — does NOT trigger on normal Cursor editor process.
//  Only matches "cursor-agent" or "cursor agent" in commands.
//

import Foundation

struct CursorAgentDetector: MiloAgentDetectorProtocol {
    let agentType: MiloAgentType = .cursorAgent

    func detect(
        from processes: [MiloAgentProcessSnapshot],
        previous event: MiloAgentEvent?
    ) -> MiloAgentEvent? {
        let matches = processes.filter { process in
            let name = process.processName.lowercased()
            let command = process.command?.lowercased() ?? ""
            return name.contains("cursor-agent")
                || command.contains("cursor-agent")
                || command.contains("cursor agent")
        }
        guard !matches.isEmpty else { return nil }
        return MiloAgentEvent(
            agentType: .cursorAgent,
            state: .running,
            title: "Cursor Agent running",
            detail: "MILO detected Cursor Agent activity.",
            startedAt: event?.startedAt ?? Date()
        )
    }
}
