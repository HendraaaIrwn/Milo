//
//  MiloAgentIntegrationsSettingsView.swift
//  Milo
//

import SwiftUI

struct MiloAgentIntegrationsSettingsView: View {
    @ObservedObject var settingsStore: MiloAgentIntegrationsSettingsStore
    @ObservedObject var manager: MiloPerAgentIntegrationManager
    let claudeIntegration: MiloClaudeCodeIntegration?

    @State private var selectedDetailAgent: MiloAgentType?
    @State private var showingSnippet: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                explanationCard

                VStack(spacing: 12) {
                    ForEach(settingsStore.configs) { config in
                        if isHookAgent(config.agentType), let integration = claudeIntegration {
                            MiloAgentIntegrationCardView(
                                config: config,
                                isOperating: manager.activeOperationAgent == config.agentType,
                                onConnect: { manager.connect(config.agentType) },
                                onTest: { runHookTest(agentType: config.agentType, integration: integration) },
                                onDisconnect: { manager.disconnect(config.agentType) },
                                onDetails: { selectedDetailAgent = config.agentType }
                            )
                            hookExtraButtons(agentType: config.agentType, integration: integration)
                        } else {
                            MiloAgentIntegrationCardView(
                                config: config,
                                isOperating: manager.activeOperationAgent == config.agentType,
                                onConnect: { manager.connect(config.agentType) },
                                onTest: { manager.testConnection(config.agentType) },
                                onDisconnect: { manager.disconnect(config.agentType) },
                                onDetails: { selectedDetailAgent = config.agentType }
                            )
                        }
                    }
                }

                Divider()

                HStack {
                    Text("Connected: \(manager.connectedCount) / \(manager.totalCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Disconnect All", role: .destructive) {
                        manager.disconnectAll()
                    }
                    .controlSize(.small)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $selectedDetailAgent) { agentType in
            if isHookAgent(agentType), let integration = claudeIntegration {
                ClaudeCodeIntegrationDetailsView(
                    agentType: agentType,
                    config: settingsStore.config(for: agentType),
                    settingsStore: settingsStore,
                    miloctlBundlePath: integration.miloctlInstallPath,
                    localReceiverRunning: integration.isRunning,
                    miloctlInstalled: integration.miloctlInstalled,
                    lastEventName: settingsStore.config(for: agentType).lastHookEventName,
                    lastReceivedAt: settingsStore.config(for: agentType).lastHookReceivedAt,
                    onClose: { selectedDetailAgent = nil },
                    onCopySnippet: { showingSnippet = true }
                )
                .sheet(isPresented: $showingSnippet) {
                    AgentHookSnippetSheet(agentType: agentType, miloctlPath: integration.miloctlInstallPath ?? "~/.milo/bin/miloctl") {
                        showingSnippet = false
                    }
                }
            } else {
                MiloAgentIntegrationDetailView(
                    config: settingsStore.config(for: agentType),
                    settingsStore: settingsStore,
                    onClose: { selectedDetailAgent = nil }
                )
            }
        }
    }

    @ViewBuilder
    private func hookExtraButtons(agentType: MiloAgentType, integration: MiloClaudeCodeIntegration) -> some View {
        HStack(spacing: 6) {
            Button {
                showingSnippet = true
            } label: {
                Label("Copy Hook Snippet", systemImage: "doc.on.doc")
            }
            .controlSize(.small)
            Spacer()
        }
        .sheet(isPresented: $showingSnippet) {
            AgentHookSnippetSheet(agentType: agentType, miloctlPath: integration.miloctlInstallPath ?? "~/.milo/bin/miloctl") {
                showingSnippet = false
            }
        }
    }

    private func runHookTest(agentType: MiloAgentType, integration: MiloClaudeCodeIntegration) {
        if !integration.isRunning {
            integration.start()
        }
        settingsStore.setStatus(.testing, for: agentType)
        integration.runTest(agentType: agentType) { success, error in
            if success {
                settingsStore.setStatus(.testPassed, for: agentType)
            } else {
                settingsStore.setStatus(.testFailed, for: agentType, errorMessage: error)
            }
        }
    }

    private func isHookAgent(_ agentType: MiloAgentType) -> Bool {
        agentType == .codex || agentType == .claudeCode
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MILO will not scan or detect agents until you connect them individually.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("MILO uses lightweight local detection and does not read prompts, outputs, source code, terminal logs, clipboard, or secrets.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
        )
    }
}

private struct AgentHookSnippetSheet: View {
    let agentType: MiloAgentType
    let miloctlPath: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(agentType == .codex ? "Codex Hook Snippet" : "Claude Code Hook Snippet")
                    .font(.headline)
                Spacer()
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

            Divider()

            ScrollView {
                ClaudeHookSnippetView(agentType: agentType, miloctlPath: miloctlPath)
                    .padding(20)
            }
        }
        .frame(width: 520, height: 560)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
