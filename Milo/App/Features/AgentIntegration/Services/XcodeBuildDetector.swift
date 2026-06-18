//
//  XcodeBuildDetector.swift
//  Milo
//
//  PRIVACY: Detects Xcode build tool processes by process name only.
//  Does not read build output, source code, command arguments, or project files.
//
//  Lightweight detection: process name only — no log/file/argument scanning.
//  Wording must be "Xcode build finished" — never "succeeded/failed" without
//  Managed Build mode providing reliable exit codes.
//

import Foundation

struct XcodeBuildDetector: MiloAgentDetectorProtocol {
    let agentType: MiloAgentType = .xcodeBuild

    private let keywords = [
        "xcodebuild",
        "xcbuild",
        "xcbbuildservice",
        "xcbbuildserviceworker",
        "swift-frontend",
        "swiftc",
        "clang",
        "ld",
        "ibtool",
        "actool",
        "codesign"
    ]

    func detect(
        from processes: [MiloAgentProcessSnapshot],
        previous event: MiloAgentEvent?
    ) -> MiloAgentEvent? {
        let matches = processes.filter { process in
            let name = normalizedProcessName(process.processName)
            return keywords.contains { name.contains($0) }
        }

        #if DEBUG
        if !matches.isEmpty {
            let matchedNames = matches.map(\.processName).joined(separator: ", ")
            MiloAgentDebugLogger.log("Xcode matched processes: \(matchedNames)")
        }
        #endif

        guard !matches.isEmpty else {
            return nil
        }

        return MiloAgentEvent(
            agentType: .xcodeBuild,
            state: .running,
            title: "Xcode build running",
            detail: "MILO detected an active Xcode build process.",
            startedAt: event?.startedAt ?? Date()
        )
    }

    private func normalizedProcessName(_ processName: String) -> String {
        let lastPathComponent = URL(fileURLWithPath: processName).lastPathComponent
        return lastPathComponent.lowercased()
    }
}
