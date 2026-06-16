//
//  AppearanceSettingsView.swift
//  Milo
//

import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @AppStorage(MiloStorageKeys.codingMetricsShowBadge) private var showCodingMetricsBadge = true
    @AppStorage(MiloStorageKeys.pomodoroShowTimerBadge) private var showPomodoroBadge = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Companion", subtitle: "Visual behavior of the floating pet.", systemImage: "eye") {
                Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
            }

            SettingsCardView(title: "Badges", subtitle: "Small indicators that appear under MILO.", systemImage: "sparkles") {
                Toggle("Show Pomodoro Timer Badge", isOn: $showPomodoroBadge)
                Toggle("Show Coding Metrics Badge", isOn: $showCodingMetricsBadge)
            }
        }
    }
}
