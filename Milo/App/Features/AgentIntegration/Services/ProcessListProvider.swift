//
//  ProcessListProvider.swift
//  Milo
//
//  PRIVACY: Runs /bin/ps to get process metadata. Output is parsed in-memory
//  and discarded immediately. Runs on background thread to avoid blocking MainActor.
//  Use lightweight scan by default — full command args only when explicitly enabled.
//

import Foundation

struct ProcessListProvider {
    func currentProcesses(includeCommandArguments: Bool = false) async -> [MiloAgentProcessSnapshot] {
        await Task.detached(priority: .background) {
            if includeCommandArguments {
                return Self.scanProcessesWithCommands()
            } else {
                return Self.scanProcessesLightweight()
            }
        }.value
    }

    private static func scanProcessesLightweight() -> [MiloAgentProcessSnapshot] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-axo", "pid=,comm="]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return [] }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return [] }
            return parseLightweightOutput(output)
        } catch {
            return []
        }
    }

    private static func scanProcessesWithCommands() -> [MiloAgentProcessSnapshot] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-axo", "pid=,comm=,command="]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return [] }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return [] }
            return parseFullOutput(output)
        } catch {
            return []
        }
    }

    private static func parseLightweightOutput(_ output: String) -> [MiloAgentProcessSnapshot] {
        output
            .split(separator: "\n")
            .compactMap { line in
                let text = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return nil }
                let parts = text.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                guard parts.count >= 2, let pid = Int32(parts[0]) else { return nil }
                return MiloAgentProcessSnapshot(
                    id: pid, pid: pid,
                    processName: String(parts[1]),
                    command: nil, startedAt: nil
                )
            }
    }

    private static func parseFullOutput(_ output: String) -> [MiloAgentProcessSnapshot] {
        output
            .split(separator: "\n")
            .compactMap { line in
                let text = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return nil }
                let parts = text.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count >= 2, let pid = Int32(parts[0]) else { return nil }
                return MiloAgentProcessSnapshot(
                    id: pid, pid: pid,
                    processName: String(parts[1]),
                    command: parts.count >= 3 ? String(parts[2]) : nil,
                    startedAt: nil
                )
            }
    }
}
