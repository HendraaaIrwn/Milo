//
//  CodingMetricsSettingsView.swift
//  Milo
//
//  PRIVACY: The WakaTime API key is stored in macOS Keychain, not UserDefaults. Local metrics are never uploaded.
//

import SwiftUI

struct CodingMetricsSettingsView: View {
    @AppStorage(MiloStorageKeys.codingMetricsEnabled) private var metricsEnabled = true
    @AppStorage(MiloStorageKeys.codingMetricsShowBadge) private var showBadge = true

    var onOpenFileWatcherSettings: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Form {
                    Section {
                        Toggle("Enable Coding Metrics", isOn: $metricsEnabled)
                        Toggle("Show Metrics Badge Under MILO", isOn: $showBadge)
                    }
                }
                .formStyle(.grouped)

                Form {
                    Section("LOC Tracking") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Project folders are managed in File Watcher Settings.", systemImage: "folder.badge.gearshape")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)

                            Label("LOC tracking uses Git. Install Git CLI tools and make sure your project folder is a Git repository.", systemImage: "info.circle")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)

                            Button("Open File Watcher Settings") {
                                onOpenFileWatcherSettings()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .formStyle(.grouped)

                Text("WakaTime Connection")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                WakaTimeConnectionView()
            }
        }
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    CodingMetricsSettingsView()
        .frame(width: 640, height: 520)
}
#endif
