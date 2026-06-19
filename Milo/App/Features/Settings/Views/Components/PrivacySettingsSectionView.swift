//
//  PrivacySettingsSectionView.swift
//  Milo
//

import SwiftUI
import AppKit

struct PrivacySettingsSectionView: View {
    private var metrics = MiloScaledMetrics()

    @State private var hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            SettingsCardView(title: "Data Stored Locally", subtitle: "What MILO keeps on your Mac.", systemImage: "lock.shield") {
                VStack(alignment: .leading, spacing: 4) {
                    bullet("Last keyboard event timestamp")
                    bullet("Typing intensity (inactive / slow / normal / fast)")
                    bullet("Active / inactive state")
                    bullet("Active app/editor name and bundle ID")
                    bullet("User-selected project folder paths")
                    bullet("File extensions for language estimation")
                    bullet("Git diff shortstat and numstat summaries")
                    bullet("Session duration and LOC summary")
                }
                .miloFont(.caption)
            }

            SettingsCardView(title: "Never Stored or Sent", subtitle: "MILO does not collect or upload these.", systemImage: "xmark.shield") {
                VStack(alignment: .leading, spacing: 4) {
                    bullet("Typed characters or key values")
                    bullet("Source code or clipboard content")
                    bullet("Keyboard history or per-key logs")
                    bullet("App or window focus information")
                    bullet("File contents from watched folders")
                }
                .miloFont(.caption)
            }

            SettingsCardView(title: "Input Monitoring Permission", subtitle: "Global typing detection needs permission.", systemImage: "hand.raised") {
                VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                    permissionStatus

                    Text("MILO still runs without this permission, but typing reactions use local monitoring only.")
                        .miloFont(.caption).foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                        Button("Request Permission") {
                            KeyboardActivityPermission.requestInputMonitoringAccess()
                            refreshPermissionSoon()
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))

                        Button("Open Input Monitoring") {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    }
                    .padding(.top, metrics.largeSpacing)
                }
            }
        }
        .onAppear { hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard }
    }

    private var permissionStatus: some View {
        Group {
            if hasKeyboardPermission {
                Label("Permission granted", systemImage: "checkmark.circle.fill")
                    .miloFont(.caption).foregroundStyle(.green)
            } else {
                Label("Permission not granted.", systemImage: "exclamationmark.triangle.fill")
                    .miloFont(.caption).foregroundStyle(.orange)
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: metrics.smallSpacing) {
            Text("•")
            Text(text).lineLimit(nil).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func refreshPermissionSoon() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
        }
    }
}