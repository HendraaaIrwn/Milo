//
//  FileWatcherSettingsView.swift
//  Milo
//
//  PRIVACY: MILO only tracks file activity metadata. File contents are never read.
//

import SwiftUI
import AppKit

struct FileWatcherSettingsView: View {
    private var metrics = MiloScaledMetrics()

    @ObservedObject var fileWatcherService: ProjectFileWatcherService

    @State private var isGlobalEnabled: Bool = UserDefaults.standard.object(
        forKey: MiloStorageKeys.fileWatcherEnabled
    ) as? Bool ?? true

    @State private var showingRemoveConfirmation: WatchedProject?
    @State private var lastUIMessage: String?

    init(fileWatcherService: ProjectFileWatcherService) {
        self.fileWatcherService = fileWatcherService
    }

    var body: some View {
        MiloResponsivePanelContainer(
            minWidth: 560,
            idealWidth: 720,
            maxWidth: 980,
            minHeight: 500,
            idealHeight: 640,
            maxHeight: 900
        ) {
            VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                header
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
                footer
            }
        }
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
        ViewThatFits(in: .horizontal) {
            HStack(spacing: metrics.mediumSpacing) {
                headerIcon
                headerText
                Spacer(minLength: metrics.smallSpacing)
                addProjectButton
            }

            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                HStack(spacing: metrics.mediumSpacing) {
                    headerIcon
                    headerText
                }
                addProjectButton
            }
        }
    }

    private var headerIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.22))
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: metrics.largeIconSize, weight: .semibold))
                .foregroundStyle(.orange)
        }
        .frame(width: metrics.largeIconSize + 22, height: metrics.largeIconSize + 22)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text("File Watcher")
                .miloFont(.title3, weight: .bold)
                .fixedSize(horizontal: false, vertical: true)
            Text("Watch project folders for real-time coding activity.")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var addProjectButton: some View {
        Button { openFolderPicker() } label: {
            Label("Add Project", systemImage: "plus")
        }
        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
    }

    private var watchedProjectsSection: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    watchedProjectsTitle
                    Spacer(minLength: metrics.smallSpacing)
                    addFolderButton
                }

                VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                    watchedProjectsTitle
                    addFolderButton
                }
            }

            if fileWatcherService.watchedProjects.isEmpty {
                EmptyWatchedProjectsView { openFolderPicker() }
            } else {
                VStack(spacing: metrics.smallSpacing) {
                    ForEach(fileWatcherService.watchedProjects) { project in
                        WatchedProjectRowView(
                            project: project,
                            onToggle: { isEnabled in
                                fileWatcherService.setProjectEnabled(id: project.id, isEnabled: isEnabled)
                            },
                            onOpenInFinder: {
                                NSWorkspace.shared.open(URL(fileURLWithPath: project.path))
                            },
                            onRemove: { showingRemoveConfirmation = project },
                            onCheckGit: {
                                fileWatcherService.refreshGitStatus(for: project.id)
                            }
                        )
                    }
                }
            }
        }
    }

    private var watchedProjectsTitle: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text("Watched Projects")
                .miloFont(.headline)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(fileWatcherService.watchedProjects.count) folder(s) added")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var addFolderButton: some View {
        Button { openFolderPicker() } label: {
            Label("Add Folder", systemImage: "folder.badge.plus")
        }
        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
    }

    private var privacyNote: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            Label("Privacy-first local watcher", systemImage: "lock.shield")
                .miloFont(.captionBold)
            Text("MILO watches file activity metadata only: path, extension, event type, timestamp, language estimate, and Git LOC summary. MILO does not store source code content or upload project activity.")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.yellow.opacity(0.10))
        )
    }

    private var footer: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: metrics.mediumSpacing) {
                footerMessage
                Spacer(minLength: metrics.smallSpacing)
                MiloStatusPill(fileWatcherService.status.title, color: statusColor)
            }

            VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                footerMessage
                MiloStatusPill(fileWatcherService.status.title, color: statusColor)
            }
        }
    }

    private var footerMessage: some View {
        Text(lastUIMessage ?? "Ignored: node_modules, .git, build, dist, DerivedData, vendor")
            .miloFont(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
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