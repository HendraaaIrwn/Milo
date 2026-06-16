//
//  WakaTimeConnectionView.swift
//  Milo
//
//  PRIVACY: WakaTime API key is stored in macOS Keychain.
//  MILO never logs or displays the full API key.
//

import SwiftUI

struct WakaTimeConnectionView: View {
    @StateObject private var store = WakaTimeConnectionStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            connectionCard
            apiKeyForm
            actionButtons
            detailInfo
            debugPanel
            footerInfo
        }
        .onAppear {
            store.refreshSavedKeyState()
            store.autoTestIfKeyExists()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WakaTime Connection")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("Connect WakaTime to enrich MILO coding metrics.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            WakaTimeConnectionStatusBadge(status: store.status)
        }
    }

    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .font(.system(size: 22))
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.status.userMessage)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                    if let lastTestedAt = store.lastTestedAt {
                        Text("Last tested: \(lastTestedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2).foregroundStyle(.secondary)
                    } else if !store.hasSavedAPIKey {
                        Text("Connection has not been tested yet.")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            if store.hasSavedAPIKey {
                HStack(spacing: 6) {
                    Image(systemName: "key.fill")
                    Text("API key saved in Keychain")
                }.font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }

    private var statusIcon: String {
        switch store.status {
        case .connected: return "checkmark.seal.fill"
        case .checking: return "arrow.triangle.2.circlepath"
        case .notConnected: return "bolt.horizontal.circle"
        case .invalidAPIKey, .forbidden: return "xmark.seal.fill"
        case .badRequest: return "exclamationmark.bubble.fill"
        case .networkError: return "wifi.slash"
        case .rateLimited: return "hourglass.tophalf.filled"
        case .serverError, .unknownError: return "exclamationmark.triangle.fill"
        }
    }

    private var statusColor: Color {
        store.status.isConnected ? .green : .yellow
    }

    private var apiKeyForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("API Key").font(.caption).foregroundStyle(.secondary)
            SecureField(
                store.hasSavedAPIKey
                    ? "Enter a new API key to replace existing key"
                    : "Paste your WakaTime API key",
                text: $store.apiKeyInput
            )
            .textFieldStyle(.roundedBorder)
            Text("Your API key is stored in macOS Keychain and never logged.")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                store.saveAndTest()
            } label: {
                HStack(spacing: 4) {
                    if store.isTesting { ProgressView().scaleEffect(0.7) }
                    Text("Save & Test Connection")
                }
                .frame(maxWidth: 268)
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.isTesting || store.apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            HStack(spacing: 8) {
                Button("Test Connection") { store.testConnection() }
                    .disabled(store.isTesting || !store.hasSavedAPIKey)

                Button("Disconnect WakaTime", role: .destructive) { store.disconnect() }
                    .disabled(store.isTesting || !store.hasSavedAPIKey)
            }
        }
    }

    @ViewBuilder
    private var detailInfo: some View {
        if case .connected(let profile) = store.status {
            VStack(alignment: .leading, spacing: 6) {
                Text("Account Details").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    let name = profile.displayNameOrUsername
                    if name != "WakaTime User" {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill"); Text(name)
                        }.foregroundStyle(.secondary)
                    }
                    if let email = profile.email {
                        HStack(spacing: 4) {
                            Image(systemName: "envelope.fill"); Text(email)
                        }.foregroundStyle(.secondary)
                    }
                }.font(.caption)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.green.opacity(0.08)))
        }
    }

    @ViewBuilder
    private var debugPanel: some View {
        #if DEBUG
        Divider()
        VStack(alignment: .leading, spacing: 4) {
            Text("Debug").font(.caption.bold())
            Text("Has saved key: \(store.hasSavedAPIKey ? "Yes" : "No")")
            Text("Keychain: \(store.keychainDebug)")
            Text("Key length: \(store.savedKeyLength)")
            Text("Endpoint: \(store.lastEndpoint.isEmpty ? "-" : store.lastEndpoint)")
            Text("HTTP status: \(store.lastHTTPStatusDescription)")
            Text("Last error: \(store.lastErrorBody ?? "-")")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        #endif
    }

    private var footerInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Local coding metrics work even without WakaTime.", systemImage: "desktopcomputer")
            Label("WakaTime is optional enrichment for summaries.", systemImage: "chart.bar")
            Label("No source code is uploaded by MILO local metrics.", systemImage: "lock.shield")
        }
        .font(.caption).foregroundStyle(.secondary)
    }
}
