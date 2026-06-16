//
//  MiloSettingsView.swift
//  Milo
//

import SwiftUI

struct MiloSettingsView: View {
    let dependencies: SettingsDependencies
    @State private var selectedSection: SettingsSection

    init(dependencies: SettingsDependencies, initialSection: SettingsSection = .general) {
        self.dependencies = dependencies
        _selectedSection = State(initialValue: initialSection)
    }

    var body: some View {
        HStack(spacing: 0) {
            SettingsSidebarView(selectedSection: $selectedSection)
                .frame(width: 210)
                .background(.regularMaterial)

            Divider()

            SettingsContentContainerView(
                section: selectedSection,
                dependencies: dependencies
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 640, minHeight: 520)
    }
}
