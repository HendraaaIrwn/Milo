import AppKit

@MainActor
final class PomodoroSoundEngine {
    static let shared = PomodoroSoundEngine()

    private init() {}

    func playFocusStart() {
        guard isSoundEnabled else { return }
        MiloSoundEffectPlayer.shared.play("start-pomodoro.mp3")
    }

    func playFocusComplete() {
        guard isSoundEnabled else { return }
        MiloSoundEffectPlayer.shared.play("pomodoro-ends.mp3")
    }

    func playBreakComplete() {
        guard isSoundEnabled else { return }
        MiloSoundEffectPlayer.shared.play("start-pomodoro.mp3")
    }

    private var isSoundEnabled: Bool {
        if UserDefaults.standard.object(forKey: MiloStorageKeys.pomodoroSoundEnabled) == nil {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.pomodoroSoundEnabled)
    }
}
