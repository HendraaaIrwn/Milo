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
    private var metrics = MiloScaledMetrics()

    var onOpenFileWatcherSettings: () -> Void = {}

    init(onOpenFileWatcherSettings: @escaping () -> Void = {}) {
        self.onOpenFileWatcherSettings = onOpenFileWatcherSettings
    }

    var body: some View {
        MiloResponsivePanelContainer(
            minWidth: 560,
            idealWidth: 720,
            maxWidth: 920,
            minHeight: 520,
            idealHeight: 680,
            maxHeight: 860
        ) {
            VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                Form {
                    Section {
                        Toggle("Enable Coding Metrics", isOn: $metricsEnabled)
                        Toggle("Show Metrics Badge Under MILO", isOn: $showBadge)
                    }
                }
                .formStyle(.grouped)

                Form {
                    Section("LOC Tracking") {
                        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                            Label("Project folders are managed in File Watcher Settings.", systemImage: "folder.badge.gearshape")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Label("LOC tracking uses Git. Install Git CLI tools and make sure your project folder is a Git repository.", systemImage: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Button("Open File Watcher Settings") {
                                onOpenFileWatcherSettings()
                            }
                            .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .formStyle(.grouped)

                Text("WakaTime Connection")
                    .font(.headline)
                    .padding(.top, metrics.smallSpacing)

                WakaTimeConnectionView()
            }
        }
    }
}

#if DEBUG
#Preview {
    CodingMetricsSettingsView()
        .dynamicTypeSize(.accessibility1)
}
#endif
