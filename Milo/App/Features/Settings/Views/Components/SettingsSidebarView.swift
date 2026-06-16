//
//  SettingsSidebarView.swift
//  Milo
//

import SwiftUI

struct SettingsSidebarView: View {
    @Binding var selectedSection: SettingsSection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sidebarHeader

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(SettingsSection.allCases) { section in
                        SettingsSidebarRow(
                            section: section,
                            isSelected: selectedSection == section
                        ) {
                            selectedSection = section
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
    }

    private var sidebarHeader: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.yellow.opacity(0.25))
                Text("M")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.orange)
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("MILO")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text("Settings")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
    }
}

private struct SettingsSidebarRow: View {
    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.iconName)
                    .frame(width: 18)
                    .foregroundStyle(isSelected ? .orange : .secondary)
                Text(section.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.yellow.opacity(0.22) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
