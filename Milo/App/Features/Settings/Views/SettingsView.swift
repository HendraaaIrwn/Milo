//
//  SettingsView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

enum MiloSettingsKeys {
    static let showMiloOnLaunch = "showMiloOnLaunch"
    static let soundEnabled = "soundEnabled"
    static let eyeFollowCursor = "eyeFollowCursor"
    static let typingReaction = "typingReaction"
    static let typingBubbleDialogs = "typingBubbleDialogs"
    static let breakNudgesEnabled = "breakNudgesEnabled"
    static let responseMode = "miloResponseMode"
}

struct SettingsView: View {
    @StateObject private var settingsStore = MiloSettingsStore()
    @ObservedObject var pomodoroService: PomodoroService

    @AppStorage(MiloSettingsKeys.showMiloOnLaunch) private var showMiloOnLaunch = true
    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @AppStorage(MiloSettingsKeys.typingReaction) private var typingReaction = true
    @AppStorage(MiloSettingsKeys.typingBubbleDialogs) private var typingBubbleDialogs = true
    @AppStorage(MiloSettingsKeys.breakNudgesEnabled) private var breakNudgesEnabled = true
    @AppStorage(MiloSettingsKeys.responseMode) private var responseMode = MiloResponseMode.smartLocal.rawValue
    @AppStorage(MiloStorageKeys.reminderNotificationsEnabled) private var reminderNotificationsEnabled = true
    @AppStorage(MiloStorageKeys.reminderSoundEnabled) private var reminderSoundEnabled = true
    @AppStorage(MiloStorageKeys.pomodoroSoundEnabled) private var pomodoroSoundEnabled = true
    @AppStorage(MiloStorageKeys.pomodoroShowTimerBadge) private var pomodoroShowTimerBadge = true

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }

            Form {
                Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
            }
            .tabItem { Label("Appearance", systemImage: "paintbrush") }

            soundTab
            .tabItem { Label("Sound", systemImage: "speaker.wave.2") }

            pomodoroTab
            .tabItem { Label("Pomodoro", systemImage: "timer") }

            reminderTab
            .tabItem { Label("Reminders", systemImage: "bell") }

            Form {
                Toggle("Break Nudges Enabled", isOn: $breakNudgesEnabled)
            }
            .tabItem { Label("Break Nudges", systemImage: "figure.walk") }

            Form {
                Text("Mood check-ins placeholder")
            }
            .tabItem { Label("Mood Check-ins", systemImage: "face.smiling") }

            personalityTab
                .tabItem { Label("Personality", systemImage: "brain.head.profile") }

            Form {
                Text("Agent detection and status indicators are configured in the full settings window.")
                    .foregroundStyle(.secondary)
            }
            .tabItem { Label("Agent Integrations", systemImage: "cpu") }

            CodingMetricsSettingsView()
                .tabItem { Label("Coding Metrics", systemImage: "chart.bar") }

            PrivacySettingsView()
                .tabItem { Label("Privacy", systemImage: "hand.raised") }
        }
        .padding(16)
        .frame(width: 640, height: 520)
    }

    private var generalTab: some View {
        Form {
            Toggle("Show Milo on Launch", isOn: $showMiloOnLaunch)
            Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
            Toggle("Typing Reaction", isOn: $typingReaction)
            Toggle("Typing Bubble Dialogs", isOn: $typingBubbleDialogs)
            Text("MILO only detects keyboard timing, not what you type.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var soundTab: some View {
        Form {
            Toggle("Sound Effects", isOn: $settingsStore.soundEffectsEnabled)
            Toggle("MILO Mumble Voice", isOn: $settingsStore.characterVoiceEnabled)
            Toggle("Mute All", isOn: $settingsStore.isMuted)

            VStack(alignment: .leading, spacing: 8) {
                Text("Volume")
                Slider(value: $settingsStore.soundVolume, in: 0...1)
            }

            HStack {
                Button("Test MILO Voice") {
                    MiloMumbleEngine.shared.speak("Milo is ready to code.")
                }

                Button("Say Milo") {
                    MiloMumbleEngine.shared.speakName()
                }
            }
        }
    }

    private var reminderTab: some View {
        Form {
            Toggle("Reminder Notifications Enabled", isOn: $reminderNotificationsEnabled)
            Toggle("Reminder Sound Enabled", isOn: $reminderSoundEnabled)
            Text("Reminders stay local and are saved on this Mac only.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var pomodoroTab: some View {
        Form {
            Toggle("Pomodoro Sound Enabled", isOn: $pomodoroSoundEnabled)
            Toggle("Show Timer Badge Under MILO", isOn: $pomodoroShowTimerBadge)

            HStack {
                Button("Start 25/5") { pomodoroService.start(preset: .short) }
                Button("Start 50/10") { pomodoroService.start(preset: .medium) }
                Button("Start 90/15") { pomodoroService.start(preset: .long) }
            }

            HStack {
                Button("Pause") { pomodoroService.pause() }
                Button("Resume") { pomodoroService.resume() }
                Button("Reset") { pomodoroService.reset() }
            }

            Divider()

            Text("Pomodoros today: \(pomodoroService.stats.pomodorosToday)")
            Text("Focus time today: \(pomodoroService.stats.totalFocusSecondsToday / 60) min")
            Text("Streak: \(pomodoroService.stats.streakDays) day(s)")
            Text("Skipped breaks: \(pomodoroService.stats.skippedBreaksToday)")

            Button("Reset Stats Today") {
                pomodoroService.resetStatsToday()
            }
        }
    }

    private var personalityTab: some View {
        Form {
            Section {
                Picker("Response Mode", selection: $responseMode) {
                    Text("Classic Local").tag(MiloResponseMode.classicLocal.rawValue)
                    Text("Smart Local").tag(MiloResponseMode.smartLocal.rawValue)
                    Text("Smart Personality").tag(MiloResponseMode.smartPersonality.rawValue)
                }
                .pickerStyle(.radioGroup)

                Text(responseModeDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text("MILO Personality")
            }
        }
    }

    private var responseModeDescription: String {
        switch responseMode {
        case MiloResponseMode.classicLocal.rawValue:
            return "Simple random responses — playful but not context-aware."
        case MiloResponseMode.smartLocal.rawValue:
            return "Context-aware responses based on focus duration, typing intensity, active project, and more. All local, no cloud."
        case MiloResponseMode.smartPersonality.rawValue:
            return "Apple Intelligence enhanced responses — personalized, contextual, and playful."
        default:
            return ""
        }
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    SettingsView(pomodoroService: PomodoroService())
}
#endif
