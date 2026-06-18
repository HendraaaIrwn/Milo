//
//  main.swift
//  miloctl
//
//  Hook entrypoint for Codex and Claude Code. Reads stdin JSON,
//  sanitizes to safe metadata, sends to MILO localhost receiver, and
//  never prints or stores raw hook payloads.
//

import Foundation

@main
struct MiloCtl {
    static func main() async {
        let args = CommandLine.arguments
        guard args.count >= 2 else { exit(1) }

        switch args[1] {
        case "codex-event":
            await handleAgentEvent(agentType: .codex, args: Array(args.dropFirst(2)))
        case "claude-event":
            await handleAgentEvent(agentType: .claudeCode, args: Array(args.dropFirst(2)))
        default:
            exit(1)
        }
    }

    static func handleAgentEvent(agentType: MiloAgentType, args: [String]) async {
        let eventName = parseArgument("--event", from: args)
        let stdinData = FileHandle.standardInput.readDataToEndOfFile()
        let event = UnifiedAgentHookPayloadSanitizer().sanitize(
            agentType: agentType,
            rawEventName: eventName,
            stdinData: stdinData
        )

        do {
            let config = try MiloLocalReceiverClient.loadConfig()
            let client = MiloLocalReceiverClient(config: config, timeout: 2.0)
            try await client.send(event)
            exit(0)
        } catch {
            exit(2)
        }
    }

    static func parseArgument(_ name: String, from args: [String]) -> String? {
        guard let index = args.firstIndex(of: name),
              args.indices.contains(index + 1) else {
            return nil
        }
        return args[index + 1]
    }
}
