//
//  SettingsContentContainerView.swift
//  Milo
//

import SwiftUI

struct SettingsContentContainerView: View {
    let section: SettingsSection
    let dependencies: SettingsDependencies

    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    contentView
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .controlSize(ControlSize.large)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.22))
                Image(systemName: section.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(section.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(.regularMaterial)
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
