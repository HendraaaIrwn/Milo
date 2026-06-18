//
//  ClaudeHookSnippetView.swift
//  Milo
//
//  Displays the hook snippet the user can copy into their Claude Code
//  settings. Does not auto-edit Claude settings.
//

import SwiftUI
import AppKit

struct ClaudeHookSnippetView: View {
    let agentType: MiloAgentType
    let miloctlPath: String

    @State private var pathOverride: String
    @State private var didCopy: Bool = false
    @State private var copyResetTask: Task<Void, Never>?

    init(agentType: MiloAgentType = .claudeCode, miloctlPath: String) {
        self.agentType = agentType
        self.miloctlPath = miloctlPath
        _pathOverride = State(initialValue: miloctlPath)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hook Snippet")
                .font(.headline)

            Text("Path to miloctl")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("~/.milo/bin/miloctl", text: $pathOverride)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            Text(agentType == .codex ? "Add this to your Codex hooks (~/.codex/hooks.json):" : "Add this to your Claude Code settings (~/.claude/settings.json):")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView {
                Text(snippet)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(NSColor.textBackgroundColor).opacity(0.6))
                    )
            }
            .frame(maxHeight: 220)

            HStack {
                Button {
                    copy()
                } label: {
                    Label(didCopy ? "Copied" : "Copy Hook Snippet",
                          systemImage: didCopy ? "checkmark.circle.fill" : "doc.on.doc")
                }
                .controlSize(.small)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Manual Install")
                    .font(.caption.weight(.semibold))
                Text("1. Copy the hook snippet.")
                Text(agentType == .codex ? "2. Open Codex hooks JSON." : "2. Open Claude Code settings JSON.")
                Text("3. Merge the hooks into your existing settings.")
                Text("4. Save the file.")
                Text("5. Run Test Connection in MILO.")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("MILO does not read your prompts or agent output. The hook command only sends safe event metadata.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var snippet: String {
        let path = pathOverride.isEmpty ? miloctlPath : pathOverride
        return agentType == .codex
            ? CodexHookSnippetBuilder.build(miloctlPath: path)
            : ClaudeHookSnippetBuilder.build(miloctlPath: path)
    }

    private func copy() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(snippet, forType: .string)
        didCopy = true
        copyResetTask?.cancel()
        copyResetTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            didCopy = false
        }
    }
}
