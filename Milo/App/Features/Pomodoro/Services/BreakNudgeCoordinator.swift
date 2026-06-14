import Foundation

@MainActor
final class BreakNudgeCoordinator {
    private let pomodoroService: PomodoroService

    init(pomodoroService: PomodoroService) {
        self.pomodoroService = pomodoroService
    }

    var shouldShowBreakNudge: Bool {
        let session = pomodoroService.session

        if session.runState == .running && session.mode == .focus {
            return false
        }

        if session.mode == .breakTime {
            return false
        }

        return true
    }

    func markBreakSkippedIfNeeded() {
        if pomodoroService.session.mode == .breakTime {
            pomodoroService.skipBreak()
        }
    }
}
