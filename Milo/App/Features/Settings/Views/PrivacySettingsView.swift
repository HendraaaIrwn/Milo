//
//  PrivacySettingsView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import AppKit
import SwiftUI

/// PRIVACY: MILO only detects keyboard activity timing to animate typing.
/// MILO never reads, stores, or uploads what you type.
struct PrivacySettingsView: View {
    @State private var hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
    @AppStorage(MiloSettingsKeys.typingBubbleDialogs) private var typingBubbleDialogs = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Keyboard Activity", systemImage: "keyboard")
                        .font(.headline)

                    Text("MILO only detects keyboard activity timing to animate typing. MILO never reads, stores, or uploads what you type.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Typing Bubble Dialogs", isOn: $typingBubbleDialogs)

                    Text("Typing bubbles use intensity and timing only. MILO does not know what you typed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Data Stored", systemImage: "lock.shield")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 4) {
                        bullet("Last keyboard event timestamp")
                        bullet("Typing intensity (inactive / slow / normal / fast)")
                        bullet("Active / inactive state")
                    }
                    .font(.subheadline)
                }
                .padding(12)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Not Stored", systemImage: "xmark.shield")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 4) {
                        bullet("Typed characters or key values")
                        bullet("Source code or clipboard content")
                        bullet("Keyboard history or per-key logs")
                        bullet("App or window focus information")
                    }
                    .font(.subheadline)
                }
                .padding(12)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Coding Metrics", systemImage: "chart.bar")
                        .font(.headline)

                    Text("MILO tracks active editor, approximate project folder, language estimation from file extensions, and Git LOC summaries. Source code content is never read or stored.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 4) {
                        bullet("Active app/editor name and bundle ID")
                        bullet("User-selected project folder path")
                        bullet("File extensions for language estimation")
                        bullet("Git diff shortstat and numstat summaries")
                        bullet("Session duration and LOC summary")
                    }
                    .font(.subheadline)
                }
                .padding(12)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Input Monitoring Permission", systemImage: "hand.raised")
                        .font(.headline)

                    permissionStatus

                    Text("Global typing detection needs Input Monitoring permission. MILO still runs without it, but can only use local keyboard monitoring when available.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Button("Request Permission") {
                            KeyboardActivityPermission.requestInputMonitoringAccess()
                            KeyboardActivityPermission.requestAccessibilityAccessIfNeeded()
                            refreshPermissionSoon()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Open Accessibility") {
                            openSystemSettings("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
                        }
                        .buttonStyle(.bordered)

                        Button("Open Input Monitoring") {
                            openSystemSettings("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(12)
            }

            Spacer()
        }
        .padding(16)
        .onAppear {
            hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
        }
    }

    private var permissionStatus: some View {
        Group {
            if hasKeyboardPermission {
                Label("Permission granted", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Label("Permission not granted. Global typing may not be detected.", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }

    private func openSystemSettings(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func refreshPermissionSoon() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
        }
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    PrivacySettingsView()
        .frame(width: 640, height: 520)
}
#endif
