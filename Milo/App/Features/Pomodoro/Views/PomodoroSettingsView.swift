import SwiftUI

struct PomodoroSettingsView: View {
    @ObservedObject var pomodoroService: PomodoroService
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                PomodoroSettingsContentView(pomodoroService: pomodoroService)
                    .padding(22)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 520, minHeight: 520)
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.22))
                Image(systemName: "timer")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pomodoro")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("Start focus sessions, tune alerts, and review today’s progress.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
}

struct PomodoroSettingsContentView: View {
    @ObservedObject var pomodoroService: PomodoroService
    
    @AppStorage(MiloStorageKeys.pomodoroSoundEnabled) private var soundEnabled = true
    @AppStorage(MiloStorageKeys.pomodoroShowTimerBadge) private var showTimerBadge = true
    @State private var selectedPreset: PomodoroPreset = .short
    @State private var customFocusMinutes = 25
    @State private var customBreakMinutes = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(
                title: "Timer Controls",
                subtitle: "Start, pause, or reset the Pomodoro timer.",
                systemImage: "timer"
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    currentSession
                    presetPicker
                    customPreset
                    controlButtons
                }
            }
            
            SettingsCardView(
                title: "Preferences",
                subtitle: "Control Pomodoro sound and MILO timer badge.",
                systemImage: "slider.horizontal.3"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Pomodoro Sound Enabled", isOn: $soundEnabled)
                    Toggle("Show Timer Badge Under MILO", isOn: $showTimerBadge)
                }
            }
            
            SettingsCardView(
                title: "Today's Stats",
                subtitle: "Track focus progress for today.",
                systemImage: "chart.bar"
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: statColumns, alignment: .leading, spacing: 10) {
                        statTile("Pomodoros", value: "\(pomodoroService.stats.pomodorosToday)")
                        statTile("Focus Time", value: "\(pomodoroService.stats.totalFocusSecondsToday / 60) min")
                        statTile("Streak", value: "\(pomodoroService.stats.streakDays) day(s)")
                        statTile("Skipped Breaks", value: "\(pomodoroService.stats.skippedBreaksToday)")
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Reset Stats Today") {
                            pomodoroService.resetStatsToday()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var currentSession: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(sessionTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text(timeRemaining)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            Spacer()
            Text(pomodoroService.session.runState.rawValue.capitalized)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.yellow.opacity(0.18), in: Capsule())
        }
    }
    
    private var presetPicker: some View {
        HStack(spacing: 8) {
            presetButton(.short)
            presetButton(.medium)
            presetButton(.long)
        }
    }
    
    private var customPreset: some View {
        DisclosureGroup("Custom Timer") {
            VStack(alignment: .leading, spacing: 10) {
                Stepper("Focus: \(customFocusMinutes) min", value: $customFocusMinutes, in: 1...240)
                Stepper("Break: \(customBreakMinutes) min", value: $customBreakMinutes, in: 1...60)
                Button("Use Custom") {
                    selectedPreset = .custom(
                        focusMinutes: customFocusMinutes,
                        breakMinutes: customBreakMinutes
                    )
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 8) {
            Button("Start") { pomodoroService.start(preset: selectedPreset) }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            Button("Pause") { pomodoroService.pause() }
                .buttonStyle(.bordered)
            Button("Resume") { pomodoroService.resume() }
                .buttonStyle(.bordered)
            Button("Reset") { pomodoroService.reset() }
                .buttonStyle(.borderedProminent)
                .tint(.red)
        }
    }
    
    private var statColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    private var sessionTitle: String {
        switch pomodoroService.session.mode {
        case .focus:
            return "Focus Session"
        case .breakTime:
            return "Break Session"
        }
    }
    
    private var timeRemaining: String {
        let seconds = max(0, pomodoroService.session.remainingSeconds)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    private func presetButton(_ preset: PomodoroPreset) -> some View {
        Button(preset.title) {
            selectedPreset = preset
        }
        .buttonStyle(.bordered)
        .tint(selectedPreset.id == preset.id ? .orange : nil)
    }
    
    private func statTile(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
