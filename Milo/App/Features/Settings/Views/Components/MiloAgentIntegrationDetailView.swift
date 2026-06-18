//
//  MiloAgentIntegrationDetailView.swift
//  Milo
//

import SwiftUI

struct MiloAgentIntegrationDetailView: View {
    let config: MiloAgentIntegrationConfig
    @ObservedObject var settingsStore: MiloAgentIntegrationsSettingsStore
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    section(title: "What MILO Detects") {
                        if config.agentType == .xcodeBuild {
                            Text("MILO detects xcodebuild, swift-frontend, swiftc, clang, ld, ibtool, actool, and codesign process presence and running/done state using process names only.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("MILO detects \(config.agentType.displayName) process presence, running/done state, and task timing using safe process metadata only.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    section(title: "What MILO Never Reads") {
                        Text("Prompts, generated output, source code, terminal contents, clipboard, passwords, API keys, or private files.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if config.agentType == .xcodeBuild {
                        section(title: "Detection Mode") {
                            Text("Lightweight — process name only. Does not read build logs, DerivedData, .xcactivitylog, or project files. For accurate success/failure, Managed Build mode can run xcodebuild directly and read the exit code in a future update.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    section(title: "Connection") {
                        VStack(alignment: .leading, spacing: 4) {
                            row(label: "Status", value: config.connectionStatus.title)
                            row(label: "Last tested", value: formatDate(config.lastTestedAt))
                            row(label: "Last detected", value: formatDate(config.lastDetectedAt))
                        }
                    }

                    section(title: "Privacy Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Allow command argument detection", isOn: binding(\.allowCommandArgumentDetection))
                            Toggle("Allow safe log keyword detection", isOn: binding(\.allowSafeLogKeywordDetection))
                        }
                        .font(.caption)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
            footer
        }
        .frame(width: 460, height: 560)
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
                Text("Integration details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(config.connectionStatus.title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(statusColor.opacity(0.16)))
                .foregroundStyle(statusColor)

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Close")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Done") {
                onClose()
            }
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
            Text(title)
                .font(.headline)
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

    private func binding(_ keyPath: WritableKeyPath<MiloAgentIntegrationConfig, Bool>) -> Binding<Bool> {
        Binding(
            get: { config[keyPath: keyPath] },
            set: { newValue in
                var updated = config
                updated[keyPath: keyPath] = newValue
                settingsStore.update(updated)
            }
        )
    }

    private var statusColor: Color {
        switch config.connectionStatus {
        case .connected, .testPassed: return .green
        case .connecting, .testing:   return .orange
        case .failed, .testFailed:    return .red
        default: return .secondary
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "Never" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
