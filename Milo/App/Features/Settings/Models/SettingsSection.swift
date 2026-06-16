//
//  SettingsSection.swift
//  Milo
//

import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case appearance
    case sound
    case reminders
    case todos
    case pomodoro
    case codingMetrics
    case wakaTime
    case fileWatcher
    case privacy
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .sound: return "Sound"
        case .reminders: return "Reminders"
        case .todos: return "Todos"
        case .pomodoro: return "Pomodoro"
        case .codingMetrics: return "Coding Metrics"
        case .wakaTime: return "WakaTime"
        case .fileWatcher: return "File Watcher"
        case .privacy: return "Privacy"
        case .about: return "About"
        }
    }

    var subtitle: String {
        switch self {
        case .general: return "Basic MILO behavior and startup preferences."
        case .appearance: return "Visual style, badge visibility, and companion display."
        case .sound: return "Mumble voice, sound effects, and volume."
        case .reminders: return "Reminder notifications, sounds, and defaults."
        case .todos: return "Todo list behavior and overdue bubbles."
        case .pomodoro: return "Focus timer presets, badge, and stats."
        case .codingMetrics: return "Local coding stats and activity tracking."
        case .wakaTime: return "Optional WakaTime connection and sync."
        case .fileWatcher: return "Watched project folders and file activity."
        case .privacy: return "Local-first data and permission controls."
        case .about: return "MILO version, credits, and app info."
        }
    }

    var iconName: String {
        switch self {
        case .general: return "gearshape.fill"
        case .appearance: return "paintpalette.fill"
        case .sound: return "speaker.wave.2.fill"
        case .reminders: return "bell.badge.fill"
        case .todos: return "checklist"
        case .pomodoro: return "timer"
        case .codingMetrics: return "chart.bar.xaxis"
        case .wakaTime: return "clock.badge.checkmark"
        case .fileWatcher: return "folder.badge.gearshape"
        case .privacy: return "lock.shield.fill"
        case .about: return "info.circle.fill"
        }
    }
}
