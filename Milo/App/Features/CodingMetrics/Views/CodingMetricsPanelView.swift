//
//  CodingMetricsPanelView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsPanelView: View {
    init(
        coordinator: CodingMetricsCoordinator,
        service: CodingMetricsService,
        onOpenWeeklySummary: @escaping () -> Void = {},
        onOpenFileWatcherSettings: @escaping () -> Void = {}
    ) {
        self.coordinator = coordinator
        self.service = service
        self.onOpenWeeklySummary = onOpenWeeklySummary
        self.onOpenFileWatcherSettings = onOpenFileWatcherSettings
    }

    private var metrics = MiloScaledMetrics()
    
    @ObservedObject var coordinator: CodingMetricsCoordinator
    @ObservedObject var service: CodingMetricsService
    

    var onOpenWeeklySummary: () -> Void = {}
    var onOpenFileWatcherSettings: () -> Void = {}

    private var snapshot: CodingMetricsSnapshot {
        service.snapshot
    }

    private var hasWakaTime: Bool {
        coordinator.wakaTimeSummary != nil
    }

    private var isTracking: Bool {
        snapshot.currentSessionSeconds > 0
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Coding Metrics",
            subtitle: "Track local coding activity, editor usage, project time, and LOC.",
            systemImage: "chart.bar.xaxis",
            primaryActionTitle: "Weekly Summary",
            primaryActionSystemImage: "calendar.badge.clock",
            primaryAction: onOpenWeeklySummary
        ) {
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
                LazyVGrid(columns: metricColumns, spacing: 16) {
                    MiloMetricCardView(title: "Coding Today", value: formatSeconds(snapshot.codingSecondsToday), systemImage: "clock")
                    MiloMetricCardView(title: "Session", value: formatSeconds(snapshot.currentSessionSeconds), systemImage: "timer")
                    MiloMetricCardView(title: "Top Editor", value: snapshot.topEditor ?? "-", systemImage: "macwindow")
                    MiloMetricCardView(title: "Top Project", value: snapshot.topProject ?? "-", systemImage: "folder")
                    MiloMetricCardView(title: "Top Language", value: snapshot.topLanguage ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                    MiloMetricCardView(title: "LOC Net", value: locDisplayValue, systemImage: "plus.forwardslash.minus")
                }
            }

            gitLOCCard

            MiloPanelCardView(
                title: "WakaTime",
                subtitle: "Optional external enrichment. Local metrics still work without it.",
                trailing: AnyView(
                    MiloStatusPillView(
                        title: hasWakaTime ? "Connected" : "Not Connected",
                        systemImage: "circle.fill",
                        tone: hasWakaTime ? .success : .warning
                    )
                )
            ) {
                if let waka = coordinator.wakaTimeSummary {
                    LazyVGrid(columns: metricColumnsWaka, spacing: 16) {
                        MiloMetricCardView(title: "Time", value: formatSeconds(waka.totalSeconds), systemImage: "clock.badge.checkmark")
                        MiloMetricCardView(title: "Top Language", value: waka.topLanguage ?? "-", systemImage: "chevron.left.forwardslash.chevron.right")
                        MiloMetricCardView(title: "Top Project", value: waka.topProject ?? "-", systemImage: "folder.fill")
                        MiloMetricCardView(title: "Top Editor", value: topEditor(from: waka.editorUsage) ?? "-", systemImage: "macwindow")
                    }
                } else {
                    MiloEmptyStateView(
                        systemImage: "bolt.horizontal.circle",
                        title: "WakaTime not connected",
                        message: "Connect WakaTime from settings when you want external coding summaries. MILO keeps local metrics working without it.",
                        buttonTitle: "Refresh WakaTime",
                        buttonSystemImage: "arrow.clockwise",
                        action: coordinator.refreshWakaTime
                    )
                }
            }

            MiloPanelCardView(
                title: "Quick Actions",
                subtitle: "Manage local metrics and project activity."
            ) {
                MiloAdaptiveActionRow(spacing: 12) {
                    Button("Refresh WakaTime") {
                        coordinator.refreshWakaTime()
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.primary))

                    Button("File Watcher") {
                        onOpenFileWatcherSettings()
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    
                    Spacer()

                    Button("Reset Local Stats", role: .destructive) {
                        coordinator.localMetricsService.resetLocalStats()
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.destructive))
                }
                .padding(.top, metrics.largeSpacing)
            }
        } footer: {
            MiloPanelFooterView(
                message: "Local coding metrics stay on your Mac.",
                statusTitle: isTracking ? "Tracking" : coordinator.sourceLabel,
                statusTone: isTracking ? .success : .neutral
            )
        }
    }

    private var locDisplayValue: String {
        let loc = snapshot.locToday

        switch loc.status {
        case .ready:
            return "\(loc.netLines)"
        default:
            return "-"
        }
    }

    private var gitLOCCard: some View {
        let loc = snapshot.locToday

        return MiloPanelCardView(
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
                HStack(spacing: 14) {
                    MiloStatusPillView(title: "+\(loc.linesAdded)", systemImage: "plus.circle.fill", tone: .success)
                    MiloStatusPillView(title: "-\(loc.linesDeleted)", systemImage: "minus.circle.fill", tone: .danger)
                    MiloStatusPillView(title: "Net \(loc.netLines)", systemImage: "equal.circle.fill", tone: .info)
                    if loc.filesChanged > 0 {
                        MiloStatusPillView(title: "\(loc.filesChanged) files", systemImage: "doc.plaintext.fill", tone: .neutral)
                    }
                }

            case .unknown:
                MiloEmptyStateView(
                    systemImage: "questionmark.folder.fill",
                    title: "No LOC data yet",
                    message: "Add a project folder in File Watcher Settings to enable local Git LOC tracking. Make sure the folder is a Git repository.",
                    buttonTitle: "Open File Watcher Settings",
                    buttonSystemImage: "folder.badge.gearshape",
                    action: onOpenFileWatcherSettings
                )

            case .notGitRepository:
                MILOLOCStatusMessageView(
                    icon: "xmark.circle.fill",
                    iconColor: .orange,
                    title: "Not a Git Repository",
                    message: "This folder is not a Git repository. LOC tracking requires Git. Initialize a Git repository or select a different project folder.",
                    actionTitle: "File Watcher Settings",
                    action: onOpenFileWatcherSettings
                )

            case .permissionDenied(let msg):
                MILOLOCStatusMessageView(
                    icon: "lock.trianglebadge.exclamationmark.fill",
                    iconColor: .red,
                    title: "Permission Denied",
                    message: "MILO lost access to this folder. Re-add the project folder to refresh permission. \(msg)",
                    actionTitle: "File Watcher Settings",
                    action: onOpenFileWatcherSettings
                )

            case .gitUnavailable(let msg):
                MILOLOCStatusMessageView(
                    icon: "terminal.fill",
                    iconColor: .red,
                    title: "Git Unavailable",
                    message: "MILO could not run Git. Make sure Git CLI tools are installed. \(msg)",
                    actionTitle: "File Watcher Settings",
                    action: onOpenFileWatcherSettings
                )

            case .gitError(let msg):
                MILOLOCStatusMessageView(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .red,
                    title: "Git Error",
                    message: msg,
                    actionTitle: "File Watcher Settings",
                    action: onOpenFileWatcherSettings
                )
            }
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

    private var metricColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: 16)]
    }

    private var metricColumnsWaka: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
    }

    private func topEditor(from usage: [String: Int]) -> String? {
        usage.max(by: { $0.value < $1.value })?.key
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

// MARK: - LOC Status Message View

struct MILOLOCStatusMessageView: View {
    private var metrics = MiloScaledMetrics()

    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    init(
        icon: String,
        iconColor: Color,
        title: String,
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
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

            Button(actionTitle) {
                action()
            }
            .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
        }
        .padding(metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.08))
        )
    }
}

