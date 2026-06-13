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
}

struct SettingsView: View {
    @AppStorage(MiloSettingsKeys.showMiloOnLaunch) private var showMiloOnLaunch = true
    @AppStorage(MiloSettingsKeys.soundEnabled) private var soundEnabled = true
    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @AppStorage(MiloSettingsKeys.typingReaction) private var typingReaction = true
    @AppStorage(MiloSettingsKeys.typingBubbleDialogs) private var typingBubbleDialogs = true
    @AppStorage(MiloSettingsKeys.breakNudgesEnabled) private var breakNudgesEnabled = true

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }

            Form {
                Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
            }
            .tabItem { Label("Appearance", systemImage: "paintbrush") }

            Form {
                Toggle("Sound Enabled", isOn: $soundEnabled)
            }
            .tabItem { Label("Sound", systemImage: "speaker.wave.2") }

            Form {
                Text("Default focus: 25 minutes")
                Text("Default break: 5 minutes")
            }
            .tabItem { Label("Pomodoro", systemImage: "timer") }

            Form {
                Text("Local reminders only")
            }
            .tabItem { Label("Reminders", systemImage: "bell") }

            Form {
                Toggle("Break Nudges Enabled", isOn: $breakNudgesEnabled)
            }
            .tabItem { Label("Break Nudges", systemImage: "figure.walk") }

            Form {
                Text("Mood check-ins placeholder")
            }
            .tabItem { Label("Mood Check-ins", systemImage: "face.smiling") }

            Form {
                Text("Agent integrations placeholder")
            }
            .tabItem { Label("Agent Integrations", systemImage: "cpu") }

            Form {
                Text("Coding metrics placeholder")
            }
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
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    SettingsView()
}
#endif
