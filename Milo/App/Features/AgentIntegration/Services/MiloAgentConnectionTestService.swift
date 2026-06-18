//
//  MiloAgentConnectionTestService.swift
//  Milo
//
//  PRIVACY: Per-agent lightweight safety checks.
//  Xcode Build runs xcodebuild -version. Other agents use process name scan only.
//  Does not require the agent to be currently running.
//

import Foundation

struct MiloAgentConnectionTestService {
    private let processListProvider = ProcessListProvider()
    private let xcodeBuildTester = XcodeBuildConnectionTester()

    func preflight(_ agentType: MiloAgentType) async throws {
        switch agentType {
        case .xcodeBuild:
            try await testXcodeBuild()
        default:
            try await testProcessScanOnly()
        }
    }

    func test(_ agentType: MiloAgentType) async throws {
        try await preflight(agentType)
    }

    private func testXcodeBuild() async throws {
        try await xcodeBuildTester.testConnection(timeoutSeconds: 8)
    }

    private func testProcessScanOnly() async throws {
        let processes = await processListProvider.currentProcesses(includeCommandArguments: false)
        _ = processes.count
    }
}
