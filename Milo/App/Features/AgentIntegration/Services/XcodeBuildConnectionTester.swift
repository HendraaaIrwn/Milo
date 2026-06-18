//
//  XcodeBuildConnectionTester.swift
//  Milo
//
//  PRIVACY: Runs xcodebuild -version to check availability.
//  Runs in background thread — never blocks MainActor.
//  Does not read build logs, source code, or project files.
//

import Foundation

enum XcodeBuildConnectionError: Error {
    case xcodebuildUnavailable
    case timeout
    case nonZeroExit(Int32)
}

struct XcodeBuildConnectionTester {
    func testConnection(timeoutSeconds: TimeInterval = 8) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await self.runXcodebuildVersion() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                throw XcodeBuildConnectionError.timeout
            }
            try await group.next()
            group.cancelAll()
        }
    }

    private func runXcodebuildVersion() async throws {
        try await Task.detached(priority: .background) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
            process.arguments = ["-version"]
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            do {
                try process.run()
                process.waitUntilExit()
                guard process.terminationStatus == 0 else {
                    throw XcodeBuildConnectionError.nonZeroExit(process.terminationStatus)
                }
            } catch {
                throw XcodeBuildConnectionError.xcodebuildUnavailable
            }
        }.value
    }
}
