//
//  MiloOverlayCoordinator.swift
//  Milo
//

import AppKit
import SwiftUI

@MainActor
final class MiloOverlayCoordinator {
    private let codingBadgeController: CodingMetricsBadgeWindowController
    private let pomodoroBadgeController: MiloPomodoroBadgeWindowController
    private let todoBubbleController: MiloTodoBubbleWindowController
    private let reminderBubbleController: MiloReminderBubbleWindowController

    private let bubbleCoordinator: MiloBubbleCoordinator

    private var latestCharacterFrame: NSRect = .zero

    init(
        codingBadgeController: CodingMetricsBadgeWindowController,
        bubbleController: MiloBubbleWindowController,
        pomodoroBadgeController: MiloPomodoroBadgeWindowController,
        todoBubbleController: MiloTodoBubbleWindowController,
        reminderBubbleController: MiloReminderBubbleWindowController
    ) {
        self.codingBadgeController = codingBadgeController
        self.pomodoroBadgeController = pomodoroBadgeController
        self.todoBubbleController = todoBubbleController
        self.reminderBubbleController = reminderBubbleController
        self.bubbleCoordinator = MiloBubbleCoordinator(bubbleWindowController: bubbleController)
    }

    func configureAll() {
        codingBadgeController.configure()
        bubbleCoordinator.configureWindow()
        pomodoroBadgeController.configure()
        todoBubbleController.configure()
        reminderBubbleController.configure()
    }

    func updatePositions(relativeTo characterFrame: NSRect) {
        latestCharacterFrame = characterFrame

        codingBadgeController.updatePosition(relativeTo: characterFrame)
        bubbleCoordinator.updateCharacterFrame(characterFrame)

        if pomodoroBadgeController.isVisible {
            pomodoroBadgeController.updatePosition(relativeTo: characterFrame)
        }

        if todoBubbleController.isVisible {
            todoBubbleController.updatePosition(relativeTo: characterFrame)
        }

        if reminderBubbleController.isVisible {
            reminderBubbleController.updatePosition(relativeTo: characterFrame)
        }
    }

    // MARK: - Coding Badge

    func showCodingBadge() {
        codingBadgeController.show(relativeTo: latestCharacterFrame)
    }

    func hideCodingBadge() {
        codingBadgeController.hide()
    }

    // MARK: - Reaction / Typing Bubble (via MiloBubbleCoordinator)

    func showBubble(
        text: String,
        source: MiloBubbleSource,
        priority: MiloBubblePriority? = nil,
        duration: TimeInterval? = nil
    ) {
        bubbleCoordinator.show(
            text: text,
            source: source,
            priority: priority,
            duration: duration
        )
    }

    func hideBubble() {
        bubbleCoordinator.hideCurrentBubble()
    }

    // MARK: - Pomodoro Badge

    func updatePomodoroBadge(isRunning: Bool) {
        if isRunning {
            pomodoroBadgeController.show(relativeTo: latestCharacterFrame)
        } else {
            pomodoroBadgeController.hide()
        }
    }

    // MARK: - Todo Bubble

    func showTodoBubble(
        todo: MiloTodo,
        duration: TimeInterval? = nil,
        onDone: @escaping () -> Void,
        onOpenTodoList: @escaping () -> Void
    ) {
        bubbleCoordinator.hideCurrentBubble()
        MiloSoundEffectPlayer.shared.play("todo-sound.mp3")
        todoBubbleController.show(
            todo: todo,
            relativeTo: latestCharacterFrame,
            duration: duration,
            onDone: onDone,
            onOpenTodoList: onOpenTodoList
        )
    }

    func hideTodoBubble() {
        todoBubbleController.hide()
    }

    // MARK: - Reminder Bubble

    func showReminderBubble(
        reminder: MiloReminder,
        duration: TimeInterval? = nil,
        onDone: @escaping () -> Void,
        onSnooze5: @escaping () -> Void,
        onSnooze15: @escaping () -> Void,
        onReschedule: @escaping () -> Void
    ) {
        bubbleCoordinator.hideCurrentBubble()
        ReminderSoundEngine.shared.playReminderBubbleSound()
        reminderBubbleController.show(
            reminder: reminder,
            relativeTo: latestCharacterFrame,
            duration: duration,
            onDone: onDone,
            onSnooze5: onSnooze5,
            onSnooze15: onSnooze15,
            onReschedule: onReschedule
        )
    }

    func hideReminderBubble() {
        reminderBubbleController.hide()
    }

    // MARK: - Lifecycle

    func hideAllEventOverlays() {
        bubbleCoordinator.hideCurrentBubble()
        todoBubbleController.hide()
        reminderBubbleController.hide()
    }

    func hidePomodoroBadge() {
        pomodoroBadgeController.hide()
    }

    func destroyAll() {
        bubbleCoordinator.destroy()
        codingBadgeController.destroy()
        pomodoroBadgeController.destroy()
        todoBubbleController.destroy()
        reminderBubbleController.destroy()
    }
}
