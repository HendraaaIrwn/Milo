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
    static let breakNudgesEnabled = "breakNudgesEnabled"
}

struct SettingsView: View {
    @AppStorage(MiloSettingsKeys.showMiloOnLaunch) private var showMiloOnLaunch = true
    @AppStorage(MiloSettingsKeys.soundEnabled) private var soundEnabled = true
    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @AppStorage(MiloSettingsKeys.typingReaction) private var typingReaction = true
    @AppStorage(MiloSettingsKeys.breakNudgesEnabled) private var breakNudgesEnabled = true

    var body: some View {
        TabView {
            Form {
                Toggle("Show Milo on Launch", isOn: $showMiloOnLaunch)
                Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
                Toggle("Typing Reaction", isOn: $typingReaction)
            }
            .tabItem { Text("General") }

            Form {
                Toggle("Eye Follow Cursor", isOn: $eyeFollowCursor)
            }
            .tabItem { Text("Appearance") }

            Form {
                Toggle("Sound Enabled", isOn: $soundEnabled)
            }
            .tabItem { Text("Sound") }

            Form {
                Text("Default focus: 25 minutes")
                Text("Default break: 5 minutes")
            }
            .tabItem { Text("Pomodoro") }

            Form {
                Text("Local reminders only")
            }
            .tabItem { Text("Reminders") }

            Form {
                Toggle("Break Nudges Enabled", isOn: $breakNudgesEnabled)
            }
            .tabItem { Text("Break Nudges") }

            Form {
                Text("Mood check-ins placeholder")
            }
            .tabItem { Text("Mood Check-ins") }

            Form {
                Text("Agent integrations placeholder")
            }
            .tabItem { Text("Agent Integrations") }

            Form {
                Text("Coding metrics placeholder")
            }
            .tabItem { Text("Coding Metrics") }

            Form {
                Text("No cloud, login, or telemetry")
            }
            .tabItem { Text("Privacy") }
        }
        .padding(16)
        .frame(width: 520, height: 360)
    }
}

#Preview {
    SettingsView()
}
