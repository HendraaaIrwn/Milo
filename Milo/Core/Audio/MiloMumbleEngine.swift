//
//  MiloMumbleEngine.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import AVFoundation
import OSLog

@MainActor
final class MiloMumbleEngine {
    static let shared = MiloMumbleEngine()

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    private let audioFormat = AVAudioFormat(
        standardFormatWithSampleRate: 44_100,
        channels: 1
    )!

    private var mumbleTask: Task<Void, Never>?

    private let logger = Logger(
        subsystem: "com.milo",
        category: "Mumble"
    )

    private init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)

        do {
            try engine.start()
            playerNode.play()
        } catch {
            logger.error("MiloMumbleEngine failed to start: \(error.localizedDescription)")
        }
    }

    /// Plays a sequence of cute pip tones scaled to the length of text.
    /// This is not TTS. MILO does not pronounce words.
    /// It creates a warm mumble that gives the feeling of character speech.
    func speak(_ text: String) {
        guard isEnabled else { return }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        stop()
        ensureEngineRunning()

        let pipCount = min(12, max(1, text.count / 5))

        mumbleTask = Task { [weak self] in
            guard let self else { return }

            for _ in 0..<pipCount {
                guard !Task.isCancelled else { return }

                self.schedulePip()

                let spacing = Double.random(in: 0.085...0.130)
                try? await Task.sleep(nanoseconds: UInt64(spacing * 1_000_000_000))
            }
        }
    }

    /// Play a two-syllable melody for "Mi-lo".
    /// A4 → C#5, warm and playful.
    func speakName() {
        guard isEnabled else { return }

        stop()
        ensureEngineRunning()

        mumbleTask = Task { [weak self] in
            guard let self else { return }

            self.scheduleNameNote(frequency: 440.0, duration: 0.135, vibratoDepth: 0)

            try? await Task.sleep(nanoseconds: 165_000_000)
            guard !Task.isCancelled else { return }

            self.scheduleNameNote(frequency: 554.37, duration: 0.130, vibratoDepth: 7)
        }
    }

    func stop() {
        mumbleTask?.cancel()
        mumbleTask = nil

        playerNode.stop()
        playerNode.reset()

        if engine.isRunning {
            playerNode.play()
        }
    }

    private func ensureEngineRunning() {
        guard !engine.isRunning else {
            if !playerNode.isPlaying {
                playerNode.play()
            }
            return
        }

        do {
            try engine.start()
            playerNode.play()
        } catch {
            logger.error("MiloMumbleEngine failed to restart: \(error.localizedDescription)")
        }
    }

    private var isEnabled: Bool {
        let soundOn = defaultBool(forKey: MiloDefaultsKeys.soundEffectsEnabled, defaultValue: true)
        let characterVoiceOn = defaultBool(forKey: MiloDefaultsKeys.characterVoiceEnabled, defaultValue: true)
        let muted = UserDefaults.standard.bool(forKey: MiloDefaultsKeys.isMuted)

        return soundOn && characterVoiceOn && !muted
    }

    private var outputVolume: Float {
        let stored = UserDefaults.standard.double(forKey: MiloDefaultsKeys.soundVolume)
        let base = stored > 0 ? Float(min(1.0, stored)) : 0.7
        return base * 0.25
    }

    private func defaultBool(forKey key: String, defaultValue: Bool) -> Bool {
        guard UserDefaults.standard.object(forKey: key) != nil else { return defaultValue }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func schedulePip() {
        let sampleRate: Double = 44_100
        let frequency = Double.random(in: 300...520)
        let duration = 0.055
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let addVibrato = Double.random(in: 0...1) < 0.55

        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount),
              let channelData = buffer.floatChannelData else {
            return
        }

        buffer.frameLength = frameCount

        let samples = channelData[0]
        let volume = outputVolume

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let progress = t / duration

            let envelope: Float
            if progress < 0.10 {
                envelope = Float(progress / 0.10)
            } else if progress > 0.65 {
                envelope = Float((1.0 - progress) / 0.35)
            } else {
                envelope = 1.0
            }

            let vibratoOffset = addVibrato ? 6.0 * sin(2.0 * .pi * 5.0 * t) : 0.0
            let frequency = frequency + vibratoOffset

            let fundamental = sin(2.0 * .pi * frequency * t)
            let harmonic2 = 0.12 * sin(2.0 * .pi * frequency * 2.0 * t)
            let harmonic3 = 0.04 * sin(2.0 * .pi * frequency * 3.0 * t)

            samples[frame] = Float(fundamental + harmonic2 + harmonic3) * volume * envelope
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)

        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    private func scheduleNameNote(frequency: Double, duration: Double, vibratoDepth: Double) {
        let sampleRate: Double = 44_100
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount),
              let channelData = buffer.floatChannelData else {
            return
        }

        buffer.frameLength = frameCount

        let samples = channelData[0]
        let volume = outputVolume * 1.5

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let progress = t / duration

            let envelope: Float
            if progress < 0.08 {
                envelope = Float(progress / 0.08)
            } else {
                envelope = Float(exp(-3.5 * (progress - 0.08)))
            }

            let vibratoOffset = vibratoDepth * sin(2.0 * .pi * 5.0 * t)
            let frequency = frequency + vibratoOffset

            let fundamental = sin(2.0 * .pi * frequency * t)
            let harmonic2 = 0.20 * sin(2.0 * .pi * frequency * 2.0 * t)
            let harmonic3 = 0.06 * sin(2.0 * .pi * frequency * 3.0 * t)

            samples[frame] = Float(fundamental + harmonic2 + harmonic3) * volume * envelope
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)

        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
}
