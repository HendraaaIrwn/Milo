//
//  FileWatcherSettingsView.swift
//  Milo
//
//  PRIVACY: MILO only tracks file activity metadata. File contents are never read.
//

import SwiftUI
import AppKit

struct FileWatcherSettingsView: View {
    @ObservedObject var fileWatcherService: ProjectFileWatcherService

    @State private var isGlobalEnabled: Bool = UserDefaults.standard.object(
        forKey: MiloStorageKeys.fileWatcherEnabled
    ) as? Bool ?? true

    @State private var showingRemoveConfirmation: WatchedProject?
    @State private var lastUIMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    FileWatcherStatusCardView(
                        status: fileWatcherService.status,
                        snapshot: fileWatcherService.snapshot,
                        isGlobalEnabled: $isGlobalEnabled,
                        onToggleGlobal: handleGlobalToggle,
                        onPause: { fileWatcherService.pause() },
                        onResume: { fileWatcherService.resume() },
                        onReset: {
                            fileWatcherService.resetActivitySnapshot()
                            lastUIMessage = "File watcher activity reset."
                        }
                    )
                    watchedProjectsSection
                    FileWatcherRecentActivityView(snapshot: fileWatcherService.snapshot)
                    privacyNote
                }
                .padding(20)
            }
            footer
        }
        .frame(minWidth: 560, minHeight: 500)
        .confirmationDialog("Remove watched project?", isPresented: isPresentedRemoveDialog, presenting: showingRemoveConfirmation) { project in
            Button("Remove \(project.name)", role: .destructive) {
                fileWatcherService.removeProject(id: project.id)
                lastUIMessage = "Removed \(project.name)."
            }
            Button("Cancel", role: .cancel) {}
        } message: { project in
            Text("MILO will stop watching \(project.name). Your files will not be deleted.")
        }
    }

    private var isPresentedRemoveDialog: Binding<Bool> {
        Binding(
            get: { showingRemoveConfirmation != nil },
            set: { if !$0 { showingRemoveConfirmation = nil } }
        )
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.22))
                Image(systemName: "folder.badge.gearshape")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text("File Watcher")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("Watch project folders for real-time coding activity.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { openFolderPicker() } label: {
                Label("Add Project", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var watchedProjectsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Watched Projects")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("\(fileWatcherService.watchedProjects.count) folder(s) added")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button { openFolderPicker() } label: {
                    Label("Add Folder", systemImage: "folder.badge.plus")
                }
            }

            if fileWatcherService.watchedProjects.isEmpty {
                EmptyWatchedProjectsView { openFolderPicker() }
            } else {
                VStack(spacing: 8) {
                    ForEach(fileWatcherService.watchedProjects) { project in
                        WatchedProjectRowView(
                            project: project,
                            onToggle: { isEnabled in
                                fileWatcherService.setProjectEnabled(id: project.id, isEnabled: isEnabled)
                            },
                            onOpenInFinder: {
                                NSWorkspace.shared.open(URL(fileURLWithPath: project.path))
                            },
                            onRemove: { showingRemoveConfirmation = project }
                        )
                    }
                }
            }
        }
    }

    private var privacyNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Privacy-first local watcher", systemImage: "lock.shield")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            Text("MILO watches file activity metadata only: path, extension, event type, timestamp, language estimate, and Git LOC summary. MILO does not store source code content or upload project activity.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.yellow.opacity(0.10))
        )
    }

    private var footer: some View {
        HStack {
            if let lastUIMessage {
                Text(lastUIMessage).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            } else {
                Text("Ignored: node_modules, .git, build, dist, DerivedData, vendor")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Text(fileWatcherService.status.title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.16))
                .foregroundStyle(statusColor)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private var statusColor: Color {
        switch fileWatcherService.status {
        case .running: return .green
        case .paused: return .orange
        case .stopped: return .secondary
        case .error: return .red
        }
    }

    private func handleGlobalToggle(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: MiloStorageKeys.fileWatcherEnabled)
        if value {
            fileWatcherService.resume()
            lastUIMessage = "File watcher resumed."
        } else {
            fileWatcherService.pause()
            lastUIMessage = "File watcher paused."
        }
    }

    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.title = "Choose Project Folder"
        panel.message = "Choose a project folder MILO can watch for coding activity."
        panel.prompt = "Add Project"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            fileWatcherService.addProject(url: url)
            lastUIMessage = "Added \(url.lastPathComponent)."
        }
    }
}
