//
//  GeneralSettingsView.swift
//  Milo
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(MiloSettingsKeys.showMiloOnLaunch) private var showMiloOnLaunch = true
    @AppStorage(MiloSettingsKeys.typingReaction) private var typingReaction = true
    @AppStorage(MiloSettingsKeys.typingBubbleDialogs) private var typingBubbleDialogs = true

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
    }
}
