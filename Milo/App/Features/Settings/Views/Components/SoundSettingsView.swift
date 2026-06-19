//
//  SoundSettingsView.swift
//  Milo
//

import SwiftUI

struct SoundSettingsView: View {
    @StateObject private var settingsStore = MiloSettingsStore()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Audio", subtitle: "MILO Mumble is procedural voice, not TTS.", systemImage: "speaker.wave.2") {
                Toggle("Sound Effects", isOn: $settingsStore.soundEffectsEnabled)
                Toggle("MILO Mumble Voice", isOn: $settingsStore.characterVoiceEnabled)
                Toggle("Mute All", isOn: $settingsStore.isMuted)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume").miloFont(.caption).foregroundStyle(.secondary)
                    Slider(value: $settingsStore.soundVolume, in: 0...1)
                }

                HStack {
                    Button("Test Voice") { MiloMumbleEngine.shared.speak("Milo is ready to code.") }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    Button("Say Milo") { MiloMumbleEngine.shared.speakName() }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                }
            }
        }
    }
}
