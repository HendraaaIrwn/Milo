//
//  FileWatcherStatusCardView.swift
//  Milo
//

import SwiftUI

struct FileWatcherStatusCardView: View {
    let status: FileWatcherStatus
    let snapshot: ProjectActivitySnapshot

    @Binding var isGlobalEnabled: Bool

    let onToggleGlobal: (Bool) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Watcher Status")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(statusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusBadge
            }

            HStack(spacing: 12) {
                metricMiniCard(title: "Active Project", value: snapshot.activeProjectName ?? "-")
                metricMiniCard(title: "Top Language", value: snapshot.topLanguageToday ?? "-")
                metricMiniCard(title: "Changed Files", value: "\(snapshot.changedFileCountToday)")
                metricMiniCard(title: "LOC", value: "+\(snapshot.locSummary.linesAdded) / -\(snapshot.locSummary.linesDeleted)")
            }

            HStack {
                Toggle("Enable File Watcher", isOn: $isGlobalEnabled)
                    .onChange(of: isGlobalEnabled) { _, newValue in onToggleGlobal(newValue) }
                Spacer()
                Button("Pause") { onPause() }.disabled(!isGlobalEnabled)
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                Button("Resume") { onResume() }.disabled(!isGlobalEnabled)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                Button("Reset Activity", role: .destructive) { onReset() }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }

    private var statusDescription: String {
        switch status {
        case .running: return "MILO is watching your enabled project folders."
        case .paused: return "File watcher is paused. Local metrics still remain saved."
        case .stopped: return "File watcher is stopped."
        case .error(let message): return message
        }
    }

    private var statusBadge: some View {
        Text(status.title)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.16))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch status {
        case .running: return .green
        case .paused: return .orange
        case .stopped: return .secondary
        case .error: return .red
        }
    }

    private func metricMiniCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.yellow.opacity(0.10))
        )
    }
}
