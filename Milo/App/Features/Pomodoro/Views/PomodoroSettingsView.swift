import SwiftUI

struct PomodoroSettingsView: View {
    @ObservedObject var pomodoroService: PomodoroService

    @AppStorage(MiloStorageKeys.pomodoroSoundEnabled) private var soundEnabled = true
    @AppStorage(MiloStorageKeys.pomodoroShowTimerBadge) private var showTimerBadge = true
    @State private var customFocusMinutes = 25
    @State private var customBreakMinutes = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PomodoroControlView(pomodoroService: pomodoroService)

            Divider()

            Toggle("Pomodoro Sound Enabled", isOn: $soundEnabled)
            Toggle("Show Timer Badge Under MILO", isOn: $showTimerBadge)

            HStack {
                Button("Reset Stats Today") {
                    pomodoroService.resetStatsToday()
                }

                Spacer()
            }
        }
        .padding(16)
        .frame(width: 420)
    }
}
