//
//  AboutSettingsView.swift
//  Milo
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "MILO", subtitle: "Tiny coding companion for macOS.", systemImage: "terminal") {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.yellow.opacity(0.25))
                        Text("M")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .frame(width: 60, height: 60)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("MILO").font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Version 1.0").font(.caption).foregroundStyle(.secondary)
                        Text("Built with SwiftUI + AppKit").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
            }

            SettingsCardView(title: "Privacy & Design", subtitle: "Local-first, offline, privacy-friendly.", systemImage: "heart") {
                VStack(alignment: .leading, spacing: 6) {
                    Label("No cloud, no login, no telemetry.", systemImage: "checkmark")
                    Label("Local storage via UserDefaults + Keychain.", systemImage: "checkmark")
                    Label("Keyboard tracking: timing only, not content.", systemImage: "checkmark")
                    Label("Coding metrics: metadata, not source code.", systemImage: "checkmark")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}
