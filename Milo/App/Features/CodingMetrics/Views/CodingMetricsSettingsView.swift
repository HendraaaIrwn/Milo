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
    @AppStorage(MiloStorageKeys.wakaTimeEnabled) private var wakaTimeEnabled = false

    @State private var apiKey: String = ""
    @State private var projectPaths: [String] = []

    private let client = WakaTimeClient()

    var body: some View {
        Form {
            Section {
                Toggle("Enable Coding Metrics", isOn: $metricsEnabled)
                Toggle("Show Metrics Badge Under MILO", isOn: $showBadge)
            }

            Section("WakaTime Integration") {
                Toggle("Enable WakaTime", isOn: $wakaTimeEnabled)

                SecureField("WakaTime API Key", text: $apiKey)

                HStack {
                    Button("Save API Key") {
                        do {
                            try client.saveAPIKey(apiKey)
                            apiKey = ""
                        } catch {
                            // Silently fail; avoid logging sensitive data.
                        }
                    }

                    Button("Remove API Key", role: .destructive) {
                        client.deleteAPIKey()
                        apiKey = ""
                    }
                }

                Text("MILO uses local coding metrics even without a WakaTime API key.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Your API key is stored in macOS Keychain, not UserDefaults.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
            loadAPIKey()
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

    private func loadAPIKey() {
        apiKey = (try? client.loadAPIKey()) ?? ""
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
