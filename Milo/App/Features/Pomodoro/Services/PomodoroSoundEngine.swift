import AppKit

@MainActor
final class PomodoroSoundEngine {
    static let shared = PomodoroSoundEngine()

    private init() {}

    func playFocusComplete() {
        guard isSoundEnabled else { return }
        NSSound(named: "Glass")?.play()
    }

    func playBreakComplete() {
        guard isSoundEnabled else { return }
        NSSound(named: "Pop")?.play()
    }

    private var isSoundEnabled: Bool {
        if UserDefaults.standard.object(forKey: MiloStorageKeys.pomodoroSoundEnabled) == nil {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.pomodoroSoundEnabled)
    }
}
