//
//  GeneralSettingsView.swift
//  Milo
//

import SwiftUI

struct GeneralSettingsView: View {
    @State private var showMiloOnLaunch = GeneralSettingsView.boolSetting(MiloSettingsKeys.showMiloOnLaunch)
    @State private var typingReaction = GeneralSettingsView.boolSetting(MiloSettingsKeys.typingReaction)
    @State private var typingBubbleDialogs = GeneralSettingsView.boolSetting(MiloSettingsKeys.typingBubbleDialogs)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Startup", subtitle: "Control how MILO behaves on launch.", systemImage: "power") {
                Toggle("Show MILO on Launch", isOn: $showMiloOnLaunch)
            }

            SettingsCardView(title: "Keyboard Reactions", subtitle: "MILO detects typing activity timing only, never what you type.", systemImage: "keyboard") {
                Toggle("Typing Reaction Animation", isOn: $typingReaction)
                Toggle("Typing Bubble Dialogs", isOn: $typingBubbleDialogs)
            }
        }
        .onChange(of: showMiloOnLaunch) { _, value in
            UserDefaults.standard.set(value, forKey: MiloSettingsKeys.showMiloOnLaunch)
        }
        .onChange(of: typingReaction) { _, value in
            UserDefaults.standard.set(value, forKey: MiloSettingsKeys.typingReaction)
        }
        .onChange(of: typingBubbleDialogs) { _, value in
            UserDefaults.standard.set(value, forKey: MiloSettingsKeys.typingBubbleDialogs)
        }
    }

    private static func boolSetting(_ key: String) -> Bool {
        UserDefaults.standard.object(forKey: key) as? Bool ?? true
    }
}
