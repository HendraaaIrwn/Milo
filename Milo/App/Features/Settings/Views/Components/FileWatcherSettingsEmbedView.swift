//
//  FileWatcherSettingsEmbedView.swift
//  Milo
//

import SwiftUI
import AppKit

struct FileWatcherSettingsEmbedView: View {
    private var metrics = MiloScaledMetrics()

    @ObservedObject var fileWatcherService: ProjectFileWatcherService
    @State private var windowController: FileWatcherSettingsWindowController?

    init(fileWatcherService: ProjectFileWatcherService) {
        self.fileWatcherService = fileWatcherService
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            overviewCard
            privacyCard
        }
    }

    private var overviewCard: some View {
        let snapshot = fileWatcherService.snapshot

        return MiloPanelCardView(
            title: "File Watcher",
            subtitle: "Real-time local file activity monitoring.",
            trailing: AnyView(statusPill)
        ) {
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                LazyVGrid(columns: metricColumns, spacing: metrics.mediumSpacing) {
                    MiloMetricCardView(
                        title: "Active Project",
                        value: snapshot.activeProjectName ?? "-",
                        systemImage: "folder"
                    )
                    MiloMetricCardView(
                        title: "Top Language",
                        value: snapshot.topLanguageToday ?? "-",
                        systemImage: "chevron.left.forwardslash.chevron.right"
                    )
                    MiloMetricCardView(
                        title: "Changed Files",
                        value: "\(snapshot.changedFileCountToday)",
                        systemImage: "doc.on.doc"
                    )
                    MiloMetricCardView(
                        title: "LOC Net",
                        value: locNetValue,
                        systemImage: "plus.forwardslash.minus"
                    )
                }

                MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                    Button {
                        openFullSettings()
                    } label: {
                        Label("Open Full Settings", systemImage: "slider.horizontal.3")
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                }
            }
        }
    }

    
    private var privacyCard: some View {
        MiloPanelCardView(
            title: "Privacy",
            subtitle: "MILO tracks local activity metadata only."
        ) {
            HStack(alignment: .top, spacing: metrics.mediumSpacing) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: metrics.largeIconSize, weight: .semibold))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                    Text("Source code content is never stored or uploaded.")
                        .miloFont(.bodyBold)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("MILO stores path, extension, event type, timestamp, language estimate, and Git LOC summary so Coding Metrics can work locally.")
                        .miloFont(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var statusPill: some View {
        MiloStatusPill(
            fileWatcherService.status.title,
            color: statusColor,
            systemImage: statusIcon
        )
    }

    private var metricColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: metrics.mediumSpacing)]
    }

    private var statusColor: Color {
        switch fileWatcherService.status {
        case .running: return .green
        case .paused: return .orange
        case .stopped: return .secondary
        case .error: return .red
        }
    }

    private var statusIcon: String {
        switch fileWatcherService.status {
        case .running: return "circle.fill"
        case .paused: return "pause.circle.fill"
        case .stopped: return "stop.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    private var locNetValue: String {
        let netLines = fileWatcherService.snapshot.locSummary.netLines
        return netLines > 0 ? "+\(netLines)" : "\(netLines)"
    }

    private var activitySubtitle: String {
        let snapshot = fileWatcherService.snapshot

        if let lastActivityAt = snapshot.lastActivityAt {
            return "Last activity: \(lastActivityAt.formatted(date: .omitted, time: .shortened))"
        }

        return "No file activity recorded today."
    }

    private func infoPill(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: metrics.smallSpacing) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))

            Text("\(title): \(value)")
                .miloFont(.captionBold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, metrics.badgePaddingHorizontal)
        .padding(.vertical, metrics.badgePaddingVertical)
        .background(Capsule().fill(color.opacity(0.14)))
        .foregroundStyle(color)
    }

    private func languageChips(_ languages: [String: Int]) -> some View {
        let topLanguages = languages.sorted { $0.value > $1.value }.prefix(4)

        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: metrics.smallSpacing)],
            alignment: .leading,
            spacing: metrics.smallSpacing
        ) {
            ForEach(Array(topLanguages), id: \.key) { language, count in
                HStack(spacing: metrics.tinySpacing) {
                    Circle()
                        .fill(Color.orange.opacity(0.85))
                        .frame(width: 6, height: 6)

                    Text(language)
                        .miloFont(.captionBold)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text("\(count)")
                        .miloFont(.caption, weight: .medium)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, metrics.badgePaddingHorizontal)
                .padding(.vertical, metrics.badgePaddingVertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                        .fill(Color.yellow.opacity(0.10))
                )
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