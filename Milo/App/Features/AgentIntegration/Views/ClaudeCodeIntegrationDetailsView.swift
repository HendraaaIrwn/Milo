//
//  ClaudeCodeIntegrationDetailsView.swift
//  Milo
//
//  Sheet replacing the generic agent detail view for Claude Code only.
//  Shows hook-specific status, the privacy receipt, the fallback toggle,
//  and the hook snippet.
//

import SwiftUI

struct ClaudeCodeIntegrationDetailsView: View {
    let agentType: MiloAgentType
    let config: MiloAgentIntegrationConfig
    @ObservedObject var settingsStore: MiloAgentIntegrationsSettingsStore
    let miloctlBundlePath: String?
    let localReceiverRunning: Bool
    let miloctlInstalled: Bool
    let lastEventName: String?
    let lastReceivedAt: Date?
    let onClose: () -> Void
    let onCopySnippet: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    connectionSection
                    privacySection
                    fallbackSection
                    snippetSection
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
            footer
        }
        .frame(width: 460, height: 620)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.orange.opacity(0.16))
                Image(systemName: config.agentType.symbolName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(config.agentType.displayName)
                    .font(.title3.bold())
                Text("Hook integration details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(config.connectionStatus.title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.green.opacity(0.16)))
                .foregroundStyle(.green)

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var connectionSection: some View {
        section(title: "Connection") {
            VStack(alignment: .leading, spacing: 4) {
                row(label: "Connection Method", value: "Hooks")
                row(label: "Local Receiver", value: localReceiverRunning ? "Running" : "Stopped")
                row(label: "miloctl",
                    value: miloctlInstalled
                        ? (miloctlBundlePath ?? "Installed")
                        : "Missing — rebuild the app to bundle miloctl")
                row(label: "Hook", value: "Manual Install Required")
                row(label: "Fallback Watcher", value: config.fallbackEnabled ? "On" : "Off")
                row(label: "Last Event", value: lastEventName ?? "None yet")
                row(label: "Last Received", value: formatDate(lastReceivedAt))
            }
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            section(title: "What MILO Receives") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Event name")
                    Text("• Safe tool name (e.g. Edit, Read)")
                    Text("• Session hash (first 8 bytes of SHA-256)")
                    Text("• Workspace folder basename only")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            section(title: "What MILO Never Reads") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Prompt text")
                    Text("• Codex or Claude responses")
                    Text("• Tool input or tool output")
                    Text("• Source code, terminal output, clipboard")
                    Text("• Full file paths or secrets")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var fallbackSection: some View {
        section(title: "Fallback Process Watcher") {
            VStack(alignment: .leading, spacing: 6) {
                Toggle("Enable fallback process watcher", isOn: Binding(
                    get: { config.fallbackEnabled },
                    set: { newValue in
                        var updated = config
                        updated.fallbackEnabled = newValue
                        settingsStore.update(updated)
                    }
                ))
                .font(.caption)
                Text("Process Watcher is best-effort fallback. Hooks are recommended for prompt, permission, and finished events.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var snippetSection: some View {
        section(title: "Hook Snippet") {
            VStack(alignment: .leading, spacing: 6) {
                Text("Copy and merge this into your Claude Code settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    onCopySnippet()
                } label: {
                    Label("Copy Hook Snippet", systemImage: "doc.on.doc")
                }
                .controlSize(.small)
            }
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Done") { onClose() }
                .keyboardShortcut(.defaultAction)
                .controlSize(.regular)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label + ":")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "Never" }
        return date.formatted(date: .omitted, time: .shortened)
    }
}
