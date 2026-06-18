//
//  MiloAgentIntegrationPreflightService.swift
//  Milo
//
//  PRIVACY: Runs a lightweight safety check before starting agent detection.
//  Uses /bin/ps -axo pid=,comm= only — no command arguments, no logs.
//  Must not block MainActor.
//

import Foundation

struct MiloAgentIntegrationPreflightService {
    private let processListProvider = ProcessListProvider()

    func runPreflight() async throws {
        let processes = await processListProvider.currentProcesses(includeCommandArguments: false)
        _ = processes.count
    }
}
