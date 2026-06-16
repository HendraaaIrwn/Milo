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

    @State private var projectPaths: [String] = []

    var body: some View {
        Form {
            Section {
                Toggle("Enable Coding Metrics", isOn: $metricsEnabled)
                Toggle("Show Metrics Badge Under MILO", isOn: $showBadge)
            }

            Section("WakaTime Connection") {
                WakaTimeConnectionView()
                    .padding(-18)
            }

            Section("Project Folders") {
                List(projectPaths, id: \.self) { path in
                    HStack {
                        Text(path)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button("Remove") {
                            projectPaths.removeAll { $0 == path }
                            saveProjectPaths()
                        }
                    }
                }

                Button("Add Project Folder") {
                    selectProjectFolder()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadProjectPaths()
        }
    }

    private func loadProjectPaths() {
        projectPaths = MiloLocalStorageService.shared.load(
            [String].self,
            forKey: MiloStorageKeys.localProjectPaths,
            defaultValue: []
        )
    }

    private func saveProjectPaths() {
        MiloLocalStorageService.shared.save(projectPaths, forKey: MiloStorageKeys.localProjectPaths)
    }

    private func selectProjectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { result in
            guard result == .OK, let url = panel.url else { return }
            let path = url.path
            if !projectPaths.contains(path) {
                projectPaths.append(path)
                saveProjectPaths()
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
