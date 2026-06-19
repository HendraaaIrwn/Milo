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
        MiloDynamicTypeDebugWrapper {
            GeometryReader { proxy in
                if proxy.size.width < 640 {
                    verticalLayout
                } else {
                    horizontalLayout
                }
            }
        }
        .frame(minWidth: 680, idealWidth: 760, maxWidth: 1020, minHeight: 560, idealHeight: 720, maxHeight: 940)
        .miloPanelDynamicTypeLimit()
    }

    private var horizontalLayout: some View {
        HStack(spacing: 0) {
            SettingsSidebarView(selectedSection: $selectedSection)
                .frame(minWidth: 190, idealWidth: 210, maxWidth: 240)
                .background(.regularMaterial)

            Divider()

            SettingsContentContainerView(
                section: selectedSection,
                dependencies: dependencies
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var verticalLayout: some View {
        VStack(spacing: 0) {
            SettingsSidebarView(selectedSection: $selectedSection)
                .frame(minHeight: 170, maxHeight: 220)
                .background(.regularMaterial)

            Divider()

            SettingsContentContainerView(
                section: selectedSection,
                dependencies: dependencies
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
