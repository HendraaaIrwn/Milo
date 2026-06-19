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
            .miloFont(.body)
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
            .miloFont(.body)
            .tabItem { Label("Break Nudges", systemImage: "figure.walk") }

            Form {
                Text("Mood check-ins placeholder")
            }
            .tabItem { Label("Mood Check-ins", systemImage: "face.smiling") }

            personalityTab
                .tabItem { Label("Personality", systemImage: "brain.head.profile") }

            Form {
                Text("Agent integrations placeholder")
            }
            .tabItem { Label("Agent Integrations", systemImage: "cpu") }

            CodingMetricsSettingsView()
                .tabItem { Label("Coding Metrics", systemImage: "chart.bar") }

            PrivacySettingsView()
                .tabItem { Label("Privacy", systemImage: "hand.raised") }
        }
        .padding(16)
        .frame(minWidth: 640, idealWidth: 760, maxWidth: 980, minHeight: 520, idealHeight: 680, maxHeight: 900)
        .miloPanelDynamicTypeLimit()
    }

    private var generalTab: some View {
        Form {
            Toggle("Show Milo on Launch", isOn: $showMiloOnLaunch)
            Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
            Toggle("Typing Reaction", isOn: $typingReaction)
            Toggle("Typing Bubble Dialogs", isOn: $typingBubbleDialogs)
            Text("MILO only detects keyboard timing, not what you type.")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .miloFont(.body)
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

            MiloAdaptiveActionRow {
                Button("Test MILO Voice") {
                    MiloMumbleEngine.shared.speak("Milo is ready to code.")
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))

                Button("Say Milo") {
                    MiloMumbleEngine.shared.speakName()
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
            }
        }
        .miloFont(.body)
    }

    private var reminderTab: some View {
        Form {
            Toggle("Reminder Notifications Enabled", isOn: $reminderNotificationsEnabled)
            Toggle("Reminder Sound Enabled", isOn: $reminderSoundEnabled)
            Text("Reminders stay local and are saved on this Mac only.")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .miloFont(.body)
    }

    private var pomodoroTab: some View {
        Form {
            Toggle("Pomodoro Sound Enabled", isOn: $pomodoroSoundEnabled)
            Toggle("Show Timer Badge Under MILO", isOn: $pomodoroShowTimerBadge)

            MiloAdaptiveActionRow {
                Button("Start 25/5") { pomodoroService.start(preset: .short) }
                    .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                Button("Start 50/10") { pomodoroService.start(preset: .medium) }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                Button("Start 90/15") { pomodoroService.start(preset: .long) }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
            }

            MiloAdaptiveActionRow {
                Button("Pause") { pomodoroService.pause() }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                Button("Resume") { pomodoroService.resume() }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                Button("Reset") { pomodoroService.reset() }
                    .buttonStyle(MiloAdaptiveButtonStyle(.subtle))
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
        .miloFont(.body)
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
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text("MILO Personality")
            }
        }
        .miloFont(.body)
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

#if DEBUG
#Preview {
    SettingsView(pomodoroService: PomodoroService())
}
#endif
