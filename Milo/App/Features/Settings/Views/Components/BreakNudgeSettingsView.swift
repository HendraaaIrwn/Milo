//
//  BreakNudgeSettingsView.swift
//  Milo
//

import SwiftUI

struct BreakNudgeSettingsView: View {
    @AppStorage(MiloSettingsKeys.breakNudgesEnabled) private var breakNudgesEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Break Reminders", subtitle: "MILO suggests breaks during long coding sessions.", systemImage: "figure.walk") {
                Toggle("Break Nudges Enabled", isOn: $breakNudgesEnabled)
            }
        }
    }
}
