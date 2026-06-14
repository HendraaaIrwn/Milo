import Foundation

enum PomodoroMode: String, Codable, Equatable {
    case focus
    case breakTime
}

enum PomodoroRunState: String, Codable, Equatable {
    case idle
    case running
    case paused
    case completed
}

struct PomodoroSession: Codable, Identifiable, Equatable {
    let id: UUID
    var preset: PomodoroPreset
    var mode: PomodoroMode
    var runState: PomodoroRunState
    var startedAt: Date?
    var pausedAt: Date?
    var remainingSeconds: Int
    var totalFocusSeconds: Int
    var totalBreakSeconds: Int
    var completedFocus: Bool

    init(
        id: UUID = UUID(),
        preset: PomodoroPreset = .short,
        mode: PomodoroMode = .focus,
        runState: PomodoroRunState = .idle,
        startedAt: Date? = nil,
        pausedAt: Date? = nil,
        remainingSeconds: Int = PomodoroPreset.short.focusSeconds,
        totalFocusSeconds: Int = PomodoroPreset.short.focusSeconds,
        totalBreakSeconds: Int = PomodoroPreset.short.breakSeconds,
        completedFocus: Bool = false
    ) {
        self.id = id
        self.preset = preset
        self.mode = mode
        self.runState = runState
        self.startedAt = startedAt
        self.pausedAt = pausedAt
        self.remainingSeconds = remainingSeconds
        self.totalFocusSeconds = totalFocusSeconds
        self.totalBreakSeconds = totalBreakSeconds
        self.completedFocus = completedFocus
    }
}
