//
//  MiloPanelSizing.swift
//  Milo
//

import Foundation

struct MiloPanelSizing {
    let defaultSize: NSSize
    let minSize: NSSize

    static let weeklyCodingSummary = MiloPanelSizing(
        defaultSize: NSSize(width: 800, height: 720),
        minSize: NSSize(width: 640, height: 560)
    )

    static let codingMetrics = MiloPanelSizing(
        defaultSize: NSSize(width: 640, height: 680),
        minSize: NSSize(width: 600, height: 520)
    )

    static let reminderHistory = MiloPanelSizing(
        defaultSize: NSSize(width: 720, height: 640),
        minSize: NSSize(width: 560, height: 500)
    )

    static let chatReminderTodo = MiloPanelSizing(
        defaultSize: NSSize(width: 640, height: 520),
        minSize: NSSize(width: 560, height: 460)
    )

    static let addReminder = MiloPanelSizing(
        defaultSize: NSSize(width: 520, height: 420),
        minSize: NSSize(width: 480, height: 380)
    )

    static let rescheduleReminder = MiloPanelSizing(
        defaultSize: NSSize(width: 560, height: 480),
        minSize: NSSize(width: 500, height: 420)
    )

    static let todoList = MiloPanelSizing(
        defaultSize: NSSize(width: 720, height: 680),
        minSize: NSSize(width: 560, height: 520)
    )

    static let addTodo = MiloPanelSizing(
        defaultSize: NSSize(width: 560, height: 580),
        minSize: NSSize(width: 500, height: 480)
    )

    static let pomodoroSettings = MiloPanelSizing(
        defaultSize: NSSize(width: 620, height: 560),
        minSize: NSSize(width: 500, height: 460)
    )
}
