import SwiftUI

struct PomodoroControlView: View {
    @ObservedObject var pomodoroService: PomodoroService
    private var metrics = MiloScaledMetrics()

    @State private var selectedPreset: PomodoroPreset = .short
    @State private var customFocusMinutes = 25
    @State private var customBreakMinutes = 5

    var body: some View {
        MiloResponsivePanelContainer(
            minWidth: 360,
            idealWidth: 460,
            maxWidth: 620,
            minHeight: 420,
            idealHeight: 560,
            maxHeight: 760
        ) {
            VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                Text("Pomodoro")
                    .miloFont(.title2, weight: .bold)
                    .fixedSize(horizontal: false, vertical: true)

                MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                    Button("25/5") { selectedPreset = .short }
                        .buttonStyle(MiloAdaptiveButtonStyle(selectedPreset == .short ? .primary : .secondary))
                    Button("50/10") { selectedPreset = .medium }
                        .buttonStyle(MiloAdaptiveButtonStyle(selectedPreset == .medium ? .primary : .secondary))
                    Button("90/15") { selectedPreset = .long }
                        .buttonStyle(MiloAdaptiveButtonStyle(selectedPreset == .long ? .primary : .secondary))
                }

                DisclosureGroup("Custom") {
                    VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                        Stepper("Focus: \(customFocusMinutes) min", value: $customFocusMinutes, in: 1...240)
                        Stepper("Break: \(customBreakMinutes) min", value: $customBreakMinutes, in: 1...60)

                        Button("Use Custom") {
                            selectedPreset = .custom(
                                focusMinutes: customFocusMinutes,
                                breakMinutes: customBreakMinutes
                            )
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    }
                    .padding(.top, metrics.smallSpacing)
                }

                MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                    Button("Start") { pomodoroService.start(preset: selectedPreset) }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                    Button("Pause") { pomodoroService.pause() }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    Button("Resume") { pomodoroService.resume() }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    Button("Reset") { pomodoroService.reset() }
                        .buttonStyle(MiloAdaptiveButtonStyle(.subtle))
                }

                Divider()

                VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                    Text("Stats")
                        .miloFont(.headline)
                    Text("Pomodoros today: \(pomodoroService.stats.pomodorosToday)")
                    Text("Focus time today: \(pomodoroService.stats.totalFocusSecondsToday / 60) min")
                    Text("Streak: \(pomodoroService.stats.streakDays) day(s)")
                    Text("Skipped breaks: \(pomodoroService.stats.skippedBreaksToday)")
                }
                .miloFont(.body)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}