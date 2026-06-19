//
//  SettingsSidebarView.swift
//  Milo
//

import SwiftUI

struct SettingsSidebarView: View {
    private var metrics = MiloScaledMetrics()

    @Binding var selectedSection: SettingsSection

    init(selectedSection: Binding<SettingsSection>) {
        self._selectedSection = selectedSection
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sidebarHeader

            ScrollView {
                LazyVStack(spacing: metrics.tinySpacing) {
                    ForEach(SettingsSection.allCases) { section in
                        SettingsSidebarRow(
                            section: section,
                            isSelected: selectedSection == section
                        ) {
                            selectedSection = section
                        }
                    }
                }
                .padding(.horizontal, metrics.mediumSpacing)
                .padding(.vertical, metrics.smallSpacing)
            }
        }
    }

    private var sidebarHeader: some View {
        HStack(spacing: metrics.mediumSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.yellow.opacity(0.25))
                Text("M")
                    .miloFont(.roundedTitle3, weight: .black)
                    .foregroundStyle(.orange)
            }
            .frame(width: metrics.largeIconSize + 10, height: metrics.largeIconSize + 10)

            VStack(alignment: .leading, spacing: 2) {
                Text("MILO")
                    .miloFont(.headline, weight: .bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Settings")
                    .miloFont(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(metrics.cardPadding)
    }
}

private struct SettingsSidebarRow: View {
    private var metrics = MiloScaledMetrics()

    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void

    init(
        section: SettingsSection,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.section = section
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: metrics.mediumSpacing) {
                Image(systemName: section.iconName)
                    .frame(width: metrics.iconSize)
                    .foregroundStyle(isSelected ? .orange : .secondary)
                Text(section.title)
                    .miloFont(.body, weight: isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.horizontal, metrics.mediumSpacing)
            .padding(.vertical, metrics.smallSpacing)
            .background(
                RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                    .fill(isSelected ? Color.yellow.opacity(0.22) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}