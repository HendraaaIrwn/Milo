//
//  MiloAgentIntegrationCardView.swift
//  Milo
//

import SwiftUI

struct MiloAgentIntegrationCardView: View {
    let config: MiloAgentIntegrationConfig
    let isOperating: Bool
    let onConnect: () -> Void
    let onTest: () -> Void
    let onDisconnect: () -> Void
    let onDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            connectionDetails
            errorText
            buttonRow
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: config.agentType.symbolName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.orange.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(config.agentType.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            statusBadge
        }
    }

    private var connectionDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            if config.agentType == .codex || config.agentType == .claudeCode {
                HStack(spacing: 6) {
                    Text("Connection:")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("Hooks")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 6) {
                    Text("Fallback:")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(config.fallbackEnabled ? "On" : "Off")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 6) {
                    Text("Receiver:")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(config.localReceiverRunning ? "Running" : "Stopped")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 6) {
                    Text("Last Event:")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(config.lastHookEventName ?? "None")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
            }
            HStack(spacing: 6) {
                Text("Tested:")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(formatDate(config.lastTestedAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            HStack(spacing: 6) {
                Text("Detected:")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(formatDate(config.lastDetectedAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
    }

    private var errorText: some View {
        Group {
            if let error = config.lastErrorMessage,
               config.connectionStatus == .failed || config.connectionStatus == .testFailed {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var buttonRow: some View {
        HStack(spacing: 6) {
            if config.isConnected {
                Button { onTest() } label: {
                    Label("Test", systemImage: "checkmark.seal")
                }
                .disabled(isOperating)
                Button(role: .destructive) { onDisconnect() } label: {
                    Label("Disconnect", systemImage: "xmark.circle")
                }
                .disabled(isOperating)
            } else {
                Button { onConnect() } label: {
                    if isOperating {
                        HStack(spacing: 4) {
                            ProgressView().scaleEffect(0.6).controlSize(.small)
                            Text("Connect")
                        }
                    } else {
                        Label("Connect", systemImage: "link")
                    }
                }
                .disabled(isOperating)
                Button { onTest() } label: {
                    Label("Test", systemImage: "checkmark.seal")
                }
                .disabled(isOperating)
            }
            Spacer(minLength: 0)
            Button { onDetails() } label: {
                Label("Details", systemImage: "info.circle")
            }
        }
        .controlSize(.small)
        .buttonStyle(.bordered)
        .lineLimit(1)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var statusBadge: some View {
        Text(config.connectionStatus.title)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(statusColor.opacity(0.14)))
            .foregroundStyle(statusColor)
    }

    private var description: String {
        switch config.agentType {
        case .codex:           return "Detect Codex hook lifecycle events. Fallback watcher stays off by default."
        case .claudeCode:      return "Detect Claude Code hook lifecycle events. Fallback watcher stays off by default."
        case .cursorAgent:     return "Basic Cursor Agent detection. Conservative."
        case .xcodeBuild:      return "Detect active Xcode build processes."
        case .genericTerminal: return "Detect selected long-running terminal commands."
        case .unknown:         return "Unknown integration."
        }
    }

    private var statusColor: Color {
        switch config.connectionStatus {
        case .connected, .testPassed: return .green
        case .connecting, .testing:   return .orange
        case .failed, .testFailed:    return .red
        case .notConnected, .disconnected: return .secondary
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "Never" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
