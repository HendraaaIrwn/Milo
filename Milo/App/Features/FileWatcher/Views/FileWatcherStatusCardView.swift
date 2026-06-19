//
//  FileWatcherStatusCardView.swift
//  Milo
//

import SwiftUI

struct FileWatcherStatusCardView: View {
    private var metrics = MiloScaledMetrics()

    let status: FileWatcherStatus
    let snapshot: ProjectActivitySnapshot

    @Binding var isGlobalEnabled: Bool

    let onToggleGlobal: (Bool) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onReset: () -> Void

    init(
        status: FileWatcherStatus,
        snapshot: ProjectActivitySnapshot,
        isGlobalEnabled: Binding<Bool>,
        onToggleGlobal: @escaping (Bool) -> Void,
        onPause: @escaping () -> Void,
        onResume: @escaping () -> Void,
        onReset: @escaping () -> Void
    ) {
        self.status = status
        self.snapshot = snapshot
        self._isGlobalEnabled = isGlobalEnabled
        self.onToggleGlobal = onToggleGlobal
        self.onPause = onPause
        self.onResume = onResume
        self.onReset = onReset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.cardPadding) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: metrics.mediumSpacing) {
                    statusTitle
                    Spacer(minLength: metrics.smallSpacing)
                    statusBadge
                }

                VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                    statusTitle
                    statusBadge
                }
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: metrics.mediumSpacing)],
                spacing: metrics.mediumSpacing
            ) {
                MiloMetricCardView(title: "Active Project", value: snapshot.activeProjectName ?? "-", systemImage: "folder")
                MiloMetricCardView(title: "Top Language", value: snapshot.topLanguageToday ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                MiloMetricCardView(title: "Changed Files", value: "\(snapshot.changedFileCountToday)", systemImage: "doc.on.doc")
                MiloMetricCardView(title: "LOC", value: "+\(snapshot.locSummary.linesAdded) / -\(snapshot.locSummary.linesDeleted)", systemImage: "plus.forwardslash.minus")
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: metrics.mediumSpacing) {
                    Toggle("Enable File Watcher", isOn: $isGlobalEnabled)
                        .onChange(of: isGlobalEnabled) { _, newValue in onToggleGlobal(newValue) }
                    Spacer(minLength: metrics.smallSpacing)
                    actionButtons
                }

                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    Toggle("Enable File Watcher", isOn: $isGlobalEnabled)
                        .onChange(of: isGlobalEnabled) { _, newValue in onToggleGlobal(newValue) }
                    actionButtons
                }
            }
        }
        .padding(metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }

    private var statusTitle: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
                    Text("Watcher Status")
                .miloFont(.headline)
                .fixedSize(horizontal: false, vertical: true)
                    Text(statusDescription)
                        .miloFont(.caption)
                        .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionButtons: some View {
        MiloAdaptiveActionRow {
            Button("Pause") { onPause() }
                .disabled(!isGlobalEnabled)
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
            Button("Resume") { onResume() }
                .disabled(!isGlobalEnabled)
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
            Button("Reset Activity", role: .destructive) { onReset() }
                .buttonStyle(MiloAdaptiveButtonStyle(.destructive))
        }
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
            .miloFont(.captionBold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, metrics.badgePaddingHorizontal)
            .padding(.vertical, metrics.badgePaddingVertical)
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
}