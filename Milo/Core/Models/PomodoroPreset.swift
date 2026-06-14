import Foundation

enum PomodoroPreset: Codable, Equatable, Identifiable {
    case short
    case medium
    case long
    case custom(focusMinutes: Int, breakMinutes: Int)

    var id: String {
        switch self {
        case .short:
            return "25/5"
        case .medium:
            return "50/10"
        case .long:
            return "90/15"
        case .custom(let focusMinutes, let breakMinutes):
            return "custom-\(focusMinutes)-\(breakMinutes)"
        }
    }

    var title: String {
        switch self {
        case .short:
            return "25 / 5"
        case .medium:
            return "50 / 10"
        case .long:
            return "90 / 15"
        case .custom(let focusMinutes, let breakMinutes):
            return "\(focusMinutes) / \(breakMinutes)"
        }
    }

    var focusSeconds: Int {
        switch self {
        case .short:
            return 25 * 60
        case .medium:
            return 50 * 60
        case .long:
            return 90 * 60
        case .custom(let focusMinutes, _):
            return max(1, focusMinutes) * 60
        }
    }

    var breakSeconds: Int {
        switch self {
        case .short:
            return 5 * 60
        case .medium:
            return 10 * 60
        case .long:
            return 15 * 60
        case .custom(_, let breakMinutes):
            return max(1, breakMinutes) * 60
        }
    }
}
