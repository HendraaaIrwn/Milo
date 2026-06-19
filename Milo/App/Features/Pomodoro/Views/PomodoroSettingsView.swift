import SwiftUI

struct PomodoroSettingsView: View {
    private var metrics = MiloScaledMetrics()
    
    @ObservedObject var pomodoroService: PomodoroService
    
    init(pomodoroService: PomodoroService) {
        self.pomodoroService = pomodoroService
    }
    
    var body: some View {
        MiloResponsivePanelContainer(
            minWidth: 500,
            idealWidth: 620,
            maxWidth: 900,
            minHeight: 460,
            idealHeight: 560,
            maxHeight: 860
        ) {
            VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                header
                PomodoroSettingsContentView(pomodoroService: pomodoroService)
            }
        }
    }
    
    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: metrics.mediumSpacing) {
                headerIcon
                headerText
                Spacer(minLength: metrics.smallSpacing)
            }
            
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                headerIcon
                headerText
            }
        }
    }
    
    private var headerIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.22))
            Image(systemName: "timer")
                .font(.system(size: metrics.largeIconSize, weight: .semibold))
                .foregroundStyle(.orange)
        }
        .frame(width: metrics.largeIconSize + 22, height: metrics.largeIconSize + 22)
    }
    
    private var headerText: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text("Pomodoro")
                .miloFont(.title3, weight: .bold)
                .fixedSize(horizontal: false, vertical: true)
            Text("Start focus sessions, tune alerts, and review today’s progress.")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PomodoroSettingsContentView: View {
    private var metrics = MiloScaledMetrics()
    
    @ObservedObject var pomodoroService: PomodoroService
    
    @AppStorage(MiloStorageKeys.pomodoroSoundEnabled) private var soundEnabled = true
    @AppStorage(MiloStorageKeys.pomodoroShowTimerBadge) private var showTimerBadge = true
    @State private var selectedPreset: PomodoroPreset = .short
    @State private var customFocusMinutes = 25
    @State private var customBreakMinutes = 5
    @State private var isCustomTimerExpanded = false
    
    init(pomodoroService: PomodoroService) {
        self.pomodoroService = pomodoroService
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            SettingsCardView(
                title: "Timer Controls",
                subtitle: "Start, pause, or reset the Pomodoro timer.",
                systemImage: "timer"
            ) {
                VStack(alignment: .leading, spacing: metrics.cardPadding) {
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
                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    Toggle("Pomodoro Sound Enabled", isOn: $soundEnabled)
                    Toggle("Show Timer Badge Under MILO", isOn: $showTimerBadge)
                }
            }
            
            MiloPanelCardView(
                title: "Today's Stats",
                subtitle: "Track focus progress for today."
            ) {
                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    LazyVGrid(columns: statColumns, alignment: .leading, spacing: metrics.mediumSpacing) {
                        MiloMetricCardView(title: "Pomodoros", value: "\(pomodoroService.stats.pomodorosToday)", systemImage: "timer")
                        MiloMetricCardView(title: "Focus Time", value: "\(pomodoroService.stats.totalFocusSecondsToday / 60) min", systemImage: "clock")
                        MiloMetricCardView(title: "Streak", value: "\(pomodoroService.stats.streakDays) day(s)", systemImage: "flame")
                        MiloMetricCardView(title: "Skipped Breaks", value: "\(pomodoroService.stats.skippedBreaksToday)", systemImage: "figure.walk")
                    }
                    MiloAdaptiveActionRow {
                        
                        Spacer()
                        
                        Button("Reset Stats Today") {
                            pomodoroService.resetStatsToday()
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.destructive))
                        
                    }
                    .padding(metrics.cardPadding)
                }
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var currentSession: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: metrics.mediumSpacing) {
                sessionText
                Spacer(minLength: metrics.smallSpacing)
                sessionStatePill
            }
            
            VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                sessionText
                sessionStatePill
            }
        }
    }
    
    private var sessionText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sessionTitle)
                .miloFont(.bodyBold)
                .fixedSize(horizontal: false, vertical: true)
            Text(timeRemaining)
                .miloFont(.largeTitle, weight: .bold)
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }
    
    private var sessionStatePill: some View {
        MiloStatusPill(
            pomodoroService.session.runState.rawValue.capitalized,
            color: .orange,
            systemImage: "timer"
        )
    }
    
    private var presetPicker: some View {
        MiloAdaptiveActionRow {
            presetButton(.short)
            presetButton(.medium)
            presetButton(.long)
        }
    }
    
    private var customPreset: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            Button {
                withAnimation(.easeInOut(duration: 0.16)) {
                    isCustomTimerExpanded.toggle()
                }
            } label: {
                HStack(spacing: metrics.smallSpacing) {
                    Image(systemName: isCustomTimerExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .frame(width: metrics.badgeIconSize, alignment: .center)
                    
                    Text("Custom Timer")
                        .miloFont(.bodyBold)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isCustomTimerExpanded {
                customTimerFields
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var customTimerFields: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            HStack(alignment: .top , spacing: metrics.largeSpacing) {
                Stepper("Focus: \(customFocusMinutes) min", value: $customFocusMinutes, in: 1...240)
                Stepper("Break: \(customBreakMinutes) min", value: $customBreakMinutes, in: 1...60)
            }
            Button("Use Custom") {
                selectedPreset = .custom(
                    focusMinutes: customFocusMinutes,
                    breakMinutes: customBreakMinutes
                )
            }
            .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
        }
    }
    
    private var controlButtons: some View {
        MiloAdaptiveActionRow {
            Button("Start") { pomodoroService.start(preset: selectedPreset) }
                .buttonStyle(MiloAdaptiveButtonStyle(.primary))
            Button("Pause") { pomodoroService.pause() }
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
            Button("Resume") { pomodoroService.resume() }
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
            Button("Reset") { pomodoroService.reset() }
                .buttonStyle(MiloAdaptiveButtonStyle(.destructive))
        }
    }
    
    private var statColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: metrics.mediumSpacing)]
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
        .buttonStyle(MiloAdaptiveButtonStyle(selectedPreset.id == preset.id ? .primary : .secondary))
    }
    
}