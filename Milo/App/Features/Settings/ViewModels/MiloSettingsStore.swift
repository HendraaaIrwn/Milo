//
//  MiloSettingsStore.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Combine
import Foundation

@MainActor
final class MiloSettingsStore: ObservableObject {
    @Published var soundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEffectsEnabled, forKey: MiloDefaultsKeys.soundEffectsEnabled)
            stopMumbleIfNeeded()
        }
    }

    @Published var characterVoiceEnabled: Bool {
        didSet {
            UserDefaults.standard.set(characterVoiceEnabled, forKey: MiloDefaultsKeys.characterVoiceEnabled)
            stopMumbleIfNeeded()
        }
    }

    @Published var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: MiloDefaultsKeys.isMuted)
            stopMumbleIfNeeded()
        }
    }

    @Published var soundVolume: Double {
        didSet {
            UserDefaults.standard.set(soundVolume, forKey: MiloDefaultsKeys.soundVolume)
        }
    }

    init() {
        soundEffectsEnabled = Self.defaultBool(forKey: MiloDefaultsKeys.soundEffectsEnabled, defaultValue: true)
        characterVoiceEnabled = Self.defaultBool(forKey: MiloDefaultsKeys.characterVoiceEnabled, defaultValue: true)
        isMuted = UserDefaults.standard.bool(forKey: MiloDefaultsKeys.isMuted)

        let storedVolume = UserDefaults.standard.double(forKey: MiloDefaultsKeys.soundVolume)
        soundVolume = storedVolume > 0 ? min(1.0, storedVolume) : 0.7
    }

    private static func defaultBool(forKey key: String, defaultValue: Bool) -> Bool {
        guard UserDefaults.standard.object(forKey: key) != nil else { return defaultValue }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func stopMumbleIfNeeded() {
        if isMuted || !soundEffectsEnabled || !characterVoiceEnabled {
            MiloMumbleEngine.shared.stop()
        }
    }
}
