//
//  SettingsContentContainerView.swift
//  Milo
//

import SwiftUI

struct SettingsContentContainerView: View {
    private var metrics = MiloScaledMetrics()

    let section: SettingsSection
    let dependencies: SettingsDependencies

    init(
        section: SettingsSection,
        dependencies: SettingsDependencies
    ) {
        self.section = section
        self.dependencies = dependencies
    }

    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                    contentView
                }
                .padding(metrics.panelPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .controlSize(ControlSize.large)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
    }

    private var sectionHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: metrics.mediumSpacing) {
                headerIcon
                headerText
                Spacer()
            }

            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                HStack(spacing: metrics.mediumSpacing) {
                    headerIcon
                    Text(section.title)
                        .miloFont(.title3, weight: .bold)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(section.subtitle)
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, metrics.panelPadding)
        .padding(.vertical, metrics.cardPadding)
        .background(.regularMaterial)
    }

    private var headerIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.22))
            Image(systemName: section.iconName)
                .font(.system(size: metrics.largeIconSize, weight: .semibold))
                .foregroundStyle(.orange)
        }
        .frame(width: metrics.largeIconSize + 22, height: metrics.largeIconSize + 22)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(section.title)
                .miloFont(.title3, weight: .bold)
                .fixedSize(horizontal: false, vertical: true)
            Text(section.subtitle)
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    @ViewBuilder
    private var contentView: some View {
        switch section {
        case .general:
            GeneralSettingsView()
        case .appearance:
            AppearanceSettingsView()
        case .personality:
            if let store = dependencies.personalitySettingsStore,
               let avail = dependencies.availabilityService {
                MiloPersonalitySettingsView(
                    settingsStore: store,
                    availabilityService: avail,
                    onTestResponse: { await dependencies.onTestSmartPersonality?() ?? nil }
                )
            }
        case .sound:
            SoundSettingsView()
        case .reminders:
            ReminderSettingsView()
        case .todos:
            TodoSettingsView()
        case .pomodoro:
            PomodoroTabSettingsView(pomodoroService: dependencies.pomodoroService)
        case .codingMetrics:
            CodingMetricsSettingsEmbedView(coordinator: dependencies.codingMetricsCoordinator)
        case .wakaTime:
            WakaTimeConnectionView()
        case .fileWatcher:
            if let fw = dependencies.fileWatcherService {
                FileWatcherSettingsEmbedView(fileWatcherService: fw)
            }
        case .privacy:
            PrivacySettingsSectionView()
        case .about:
            AboutSettingsView()
        }
    }
}