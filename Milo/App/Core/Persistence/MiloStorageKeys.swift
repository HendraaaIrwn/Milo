//
//  MiloStorageKeys.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

enum MiloStorageKeys {
    static let reminders = "Milo.Reminders"
    static let reminderHistoryEvents = "Milo.ReminderHistoryEvents"
    static let todos = "Milo.Todos"
    static let reminderSoundEnabled = "Milo.ReminderSoundEnabled"
    static let reminderNotificationsEnabled = "Milo.ReminderNotificationsEnabled"
    static let pomodoroSession = "Milo.Pomodoro.Session"
    static let pomodoroStats = "Milo.Pomodoro.Stats"
    static let pomodoroSoundEnabled = "Milo.Pomodoro.SoundEnabled"
    static let selectedPomodoroPreset = "Milo.Pomodoro.SelectedPreset"
    static let pomodoroShowTimerBadge = "Milo.Pomodoro.ShowTimerBadge"

    // Coding Metrics
    static let codingMetricsSnapshot = "Milo.CodingMetrics.Snapshot"
    static let codingMetricsEnabled = "Milo.CodingMetrics.Enabled"
    static let codingMetricsShowBadge = "Milo.CodingMetrics.ShowBadge"
    static let codingMetricsShowWeeklySummary = "Milo.CodingMetrics.ShowWeeklySummary"
    static let localProjectPaths = "Milo.CodingMetrics.ProjectPaths"
    static let dailyCodingMetricsRecords = "Milo.CodingMetrics.DailyRecords"
    static let weeklyCodingSummaryCache = "Milo.CodingMetrics.WeeklySummaryCache"

    // WakaTime
    static let wakaTimeEnabled = "Milo.WakaTime.Enabled"
    static let wakaTimeLastTestedAt = "Milo.WakaTime.LastTestedAt"
    static let wakaTimeLastConnectedUsername = "Milo.WakaTime.LastConnectedUsername"
    static let wakaTimeLastConnectedEmail = "Milo.WakaTime.LastConnectedEmail"

    // File Watcher
    static let fileWatcherEnabled = "Milo.FileWatcher.Enabled"
    static let watchedProjects = "Milo.FileWatcher.WatchedProjects"
    static let projectActivitySnapshot = "Milo.FileWatcher.ProjectActivitySnapshot"
}
