import SwiftUI

struct PomodoroControlView: View {
    @ObservedObject var pomodoroService: PomodoroService

    @State private var selectedPreset: PomodoroPreset = .short
    @State private var customFocusMinutes = 25
    @State private var customBreakMinutes = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pomodoro")
                .font(.system(size: 20, weight: .bold, design: .rounded))

            HStack {
                Button("25/5") { selectedPreset = .short }
                Button("50/10") { selectedPreset = .medium }
                Button("90/15") { selectedPreset = .long }
            }

            DisclosureGroup("Custom") {
                Stepper("Focus: \(customFocusMinutes) min", value: $customFocusMinutes, in: 1...240)
                Stepper("Break: \(customBreakMinutes) min", value: $customBreakMinutes, in: 1...60)

                Button("Use Custom") {
                    selectedPreset = .custom(
                        focusMinutes: customFocusMinutes,
                        breakMinutes: customBreakMinutes
                    )
                }
            }

            HStack {
                Button("Start") { pomodoroService.start(preset: selectedPreset) }
                Button("Pause") { pomodoroService.pause() }
                Button("Resume") { pomodoroService.resume() }
                Button("Reset") { pomodoroService.reset() }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Stats")
                    .font(.headline)

                Text("Pomodoros today: \(pomodoroService.stats.pomodorosToday)")
                Text("Focus time today: \(pomodoroService.stats.totalFocusSecondsToday / 60) min")
                Text("Streak: \(pomodoroService.stats.streakDays) day(s)")
                Text("Skipped breaks: \(pomodoroService.stats.skippedBreaksToday)")
            }
            .font(.caption)
        }
        .padding(16)
        .frame(width: 360)
    }
}
