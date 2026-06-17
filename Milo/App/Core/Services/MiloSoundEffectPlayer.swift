//
//  MiloSoundEffectPlayer.swift
//  Milo
//

import AppKit

@MainActor
final class MiloSoundEffectPlayer {
    static let shared = MiloSoundEffectPlayer()

    private var sounds: [String: NSSound] = [:]

    private init() {}

    func play(_ fileName: String) {
        guard isEnabled else { return }
        guard let sound = sound(named: fileName) else { return }

        sound.stop()
        sound.volume = outputVolume
        sound.currentTime = 0
        sound.play()
    }

    private func sound(named fileName: String) -> NSSound? {
        if let cached = sounds[fileName] {
            return cached
        }

        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: ext,
            subdirectory: "App/Resources/Sounds"
        ) ?? Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }

        let sound = NSSound(contentsOf: url, byReference: false)
        sounds[fileName] = sound
        return sound
    }

    private var isEnabled: Bool {
        let soundOn = defaultBool(forKey: MiloDefaultsKeys.soundEffectsEnabled, defaultValue: true)
        let muted = UserDefaults.standard.bool(forKey: MiloDefaultsKeys.isMuted)
        return soundOn && !muted
    }

    private var outputVolume: Float {
        let stored = UserDefaults.standard.double(forKey: MiloDefaultsKeys.soundVolume)
        return stored > 0 ? Float(min(1.0, stored)) : 0.7
    }

    private func defaultBool(forKey key: String, defaultValue: Bool) -> Bool {
        guard UserDefaults.standard.object(forKey: key) != nil else { return defaultValue }
        return UserDefaults.standard.bool(forKey: key)
    }
}
