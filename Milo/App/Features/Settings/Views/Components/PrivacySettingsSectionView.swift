//
//  PrivacySettingsSectionView.swift
//  Milo
//

import SwiftUI
import AppKit

struct PrivacySettingsSectionView: View {
    @State private var hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                .font(.caption)
            }

            SettingsCardView(title: "Never Stored or Sent", subtitle: "MILO does not collect or upload these.", systemImage: "xmark.shield") {
                VStack(alignment: .leading, spacing: 4) {
                    bullet("Typed characters or key values")
                    bullet("Source code or clipboard content")
                    bullet("Keyboard history or per-key logs")
                    bullet("App or window focus information")
                    bullet("File contents from watched folders")
                }
                .font(.caption)
            }

            SettingsCardView(title: "Input Monitoring Permission", subtitle: "Global typing detection needs permission.", systemImage: "hand.raised") {
                VStack(alignment: .leading, spacing: 8) {
                    permissionStatus

                    Text("MILO still runs without this permission, but typing reactions use local monitoring only.")
                        .font(.caption).foregroundStyle(.secondary)

                    HStack {
                        Button("Request Permission") {
                            KeyboardActivityPermission.requestInputMonitoringAccess()
                            refreshPermissionSoon()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Open Input Monitoring") {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
                        }
                    }
                }
            }
        }
        .onAppear { hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard }
    }

    private var permissionStatus: some View {
        Group {
            if hasKeyboardPermission {
                Label("Permission granted", systemImage: "checkmark.circle.fill")
                    .font(.caption).foregroundStyle(.green)
            } else {
                Label("Permission not granted.", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption).foregroundStyle(.orange)
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) { Text("•"); Text(text) }
    }

    private func refreshPermissionSoon() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
        }
    }
}
