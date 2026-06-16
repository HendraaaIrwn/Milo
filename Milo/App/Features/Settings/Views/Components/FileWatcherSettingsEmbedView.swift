//
//  FileWatcherSettingsEmbedView.swift
//  Milo
//

import SwiftUI
import AppKit

struct FileWatcherSettingsEmbedView: View {
    @ObservedObject var fileWatcherService: ProjectFileWatcherService
    
    @State private var windowController: FileWatcherSettingsWindowController?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Status", subtitle: "Real-time file activity monitoring.", systemImage: "folder.badge.gearshape") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Status:").font(.caption).foregroundStyle(.secondary)
                        Text(fileWatcherService.status.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(fileWatcherService.status == .running ? .green : .orange)
                    }
                    Text("Active project: \(fileWatcherService.snapshot.activeProjectName ?? "-")").font(.caption)
                    Text("Top language: \(fileWatcherService.snapshot.topLanguageToday ?? "-")").font(.caption)
                    Text("Changed files today: \(fileWatcherService.snapshot.changedFileCountToday)").font(.caption)
                    Spacer()
                    Button("Open Full Settings") {
                        openFullSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
        }
    }
    
    private func openFullSettings() {
        let controller = FileWatcherSettingsWindowController(
            fileWatcherService: fileWatcherService
        )
        windowController = controller
        controller.show()
    }
}
