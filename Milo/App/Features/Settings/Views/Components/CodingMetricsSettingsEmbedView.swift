//
//  CodingMetricsSettingsEmbedView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsSettingsEmbedView: View {
    private var metrics = MiloScaledMetrics()

    let coordinator: CodingMetricsCoordinator?

    init(coordinator: CodingMetricsCoordinator?) {
        self.coordinator = coordinator
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            todayOverviewCard
            gitLOCCard
        }
    }

    @ViewBuilder
    private var todayOverviewCard: some View {
        if let coordinator {
            let snapshot = coordinator.localMetricsService.snapshot
            let hasWakaTime = coordinator.wakaTimeSummary != nil

            MiloPanelCardView(
                title: "Today Overview",
                subtitle: "Your active coding snapshot for today.",
                trailing: AnyView(
                    MiloStatusPillView(
                        title: hasWakaTime ? "Local + WakaTime" : "Local",
                        systemImage: "circle.fill",
                        tone: hasWakaTime ? .success : .neutral
                    )
                )
            ) {
                LazyVGrid(columns: metricColumns, spacing: metrics.mediumSpacing) {
                    MiloMetricCardView(title: "Coding Today", value: formatSeconds(snapshot.codingSecondsToday), systemImage: "clock")
                    MiloMetricCardView(title: "Session", value: formatSeconds(snapshot.currentSessionSeconds), systemImage: "timer")
                    MiloMetricCardView(title: "Top Editor", value: snapshot.topEditor ?? "-", systemImage: "macwindow")
                    MiloMetricCardView(title: "Top Project", value: snapshot.topProject ?? "-", systemImage: "folder")
                    MiloMetricCardView(title: "Top Language", value: snapshot.topLanguage ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                    MiloMetricCardView(title: "LOC Net", value: locDisplayValue(for: snapshot.locToday), systemImage: "plus.forwardslash.minus")
                }
            }
        } else {
            MiloPanelCardView(
                title: "Today Overview",
                subtitle: "Local coding activity snapshot for today."
            ) {
                unavailableMessage(
                    title: "Metrics service unavailable",
                    message: "MILO cannot load local coding metrics right now. Reopen Settings after app services finish starting."
                )
            }
        }
    }

    @ViewBuilder
    private var gitLOCCard: some View {
        if let coordinator {
            let loc = coordinator.localMetricsService.snapshot.locToday

            MiloPanelCardView(
                title: "Git & LOC Tracking",
                subtitle: locSubtitle(for: loc),
                trailing: AnyView(
                    MiloStatusPillView(
                        title: loc.status.title,
                        systemImage: locStatusIcon(for: loc.status),
                        tone: locStatusTone(for: loc.status)
                    )
                )
            ) {
                switch loc.status {
                case .ready:
                    MiloAdaptiveActionRow(spacing: metrics.mediumSpacing) {
                        MiloStatusPillView(title: "+\(loc.linesAdded)", systemImage: "plus.circle.fill", tone: .success)
                        MiloStatusPillView(title: "-\(loc.linesDeleted)", systemImage: "minus.circle.fill", tone: .danger)
                        MiloStatusPillView(title: "Net \(loc.netLines)", systemImage: "equal.circle.fill", tone: .info)
                        if loc.filesChanged > 0 {
                            MiloStatusPillView(title: "\(loc.filesChanged) files", systemImage: "doc.plaintext.fill", tone: .neutral)
                        }
                    }
                    .padding(.top, metrics.largeSpacing)

                case .unknown:
                    MiloEmptyStateView(
                        systemImage: "questionmark.folder.fill",
                        title: "No LOC data yet",
                        message: "Add a project folder in File Watcher Settings to enable local Git LOC tracking. Make sure the folder is a Git repository."
                    )

                case .notGitRepository:
                    locStatusMessage(
                        icon: "xmark.circle.fill",
                        iconColor: .orange,
                        title: "Not a Git Repository",
                        message: "This folder is not a Git repository. LOC tracking requires Git. Initialize a Git repository or select a different project folder."
                    )

                case .permissionDenied(let message):
                    locStatusMessage(
                        icon: "lock.trianglebadge.exclamationmark.fill",
                        iconColor: .red,
                        title: "Permission Denied",
                        message: "MILO lost access to this folder. Re-add the project folder to refresh permission. \(message)"
                    )

                case .gitUnavailable(let message):
                    locStatusMessage(
                        icon: "terminal.fill",
                        iconColor: .red,
                        title: "Git Unavailable",
                        message: "MILO could not run Git. Make sure Git CLI tools are installed. \(message)"
                    )

                case .gitError(let message):
                    locStatusMessage(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .red,
                        title: "Git Error",
                        message: message
                    )
                }
            }
        } else {
            MiloPanelCardView(
                title: "Git & LOC Tracking",
                subtitle: "Track added, deleted, net line changes, and changed files from local Git metadata only."
            ) {
                unavailableMessage(
                    title: "LOC tracking unavailable",
                    message: "MILO cannot load Git and LOC status right now. Reopen Settings after app services finish starting."
                )
            }
        }
    }

    private var metricColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: metrics.mediumSpacing)]
    }

    private func locStatusMessage(icon: String, iconColor: Color, title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            HStack(alignment: .top, spacing: metrics.smallSpacing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.body.weight(.bold))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.08))
        )
    }

    private func unavailableMessage(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            Text(title)
                .font(.body.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func locDisplayValue(for loc: LOCSummary) -> String {
        switch loc.status {
        case .ready:
            return "\(loc.netLines)"
        default:
            return "-"
        }
    }

    private func locSubtitle(for loc: LOCSummary) -> String {
        switch loc.status {
        case .ready:
            if let updatedAt = loc.lastUpdatedAt {
                return "Last updated: \(updatedAt.formatted(date: .abbreviated, time: .shortened))"
            }
            return "Git-based added, deleted, and net line changes."
        default:
            return loc.status.message
        }
    }

    private func locStatusTone(for status: LOCSummaryStatus) -> MiloStatusPillView.Tone {
        switch status {
        case .ready:
            return .success
        case .notGitRepository:
            return .warning
        case .permissionDenied, .gitUnavailable, .gitError:
            return .danger
        case .unknown:
            return .neutral
        }
    }

    private func locStatusIcon(for status: LOCSummaryStatus) -> String {
        switch status {
        case .ready:
            return "checkmark.circle.fill"
        case .notGitRepository:
            return "xmark.circle"
        case .permissionDenied:
            return "lock.fill"
        case .gitUnavailable:
            return "terminal"
        case .gitError:
            return "exclamationmark.triangle"
        case .unknown:
            return "questionmark.circle"
        }
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
}
