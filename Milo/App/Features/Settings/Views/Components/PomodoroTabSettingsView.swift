//
//  PomodoroTabSettingsView.swift
//  Milo
//

import SwiftUI

struct PomodoroTabSettingsView: View {
    var pomodoroService: PomodoroService?

    var body: some View {
        if let pomodoroService {
            PomodoroSettingsContentView(pomodoroService: pomodoroService)
        } else {
            SettingsCardView(
                title: "Timer Controls",
                subtitle: "Pomodoro service is unavailable.",
                systemImage: "timer"
            ) {
                Text("Open MILO again to enable Pomodoro controls.")
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}