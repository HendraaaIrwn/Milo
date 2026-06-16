//
//  MiloStateStore.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation
import Combine

/// PRIVACY: MILO only tracks keyboard activity timing and intensity.
/// No typed content, key codes, or input data are stored.
@MainActor
final class MiloStateStore: ObservableObject {
    @Published var animationState: MiloAnimationState = .idle
    @Published var isTyping: Bool = false
    @Published var typingIntensity: TypingIntensity = .inactive
    @Published var lastKeyboardEventAt: Date?
    @Published var typingStartedAt: Date?
    @Published var typingBubbleText: String?
    @Published var shouldShowTypingBubble: Bool = false
    @Published var isMiloVisible: Bool = false
    @Published var reminderBubbleText: String?
    @Published var activeReminder: MiloReminder?
    @Published var shouldShowReminderBubble: Bool = false
    @Published var activeTodoBubble: MiloTodo?
    @Published var shouldShowTodoBubble: Bool = false
    @Published var activeTodoCount: Int = 0
    @Published var isContextMenuOpen: Bool = false

    func setContextMenuOpen(_ isOpen: Bool) {
        isContextMenuOpen = isOpen
    }

    func setTyping(intensity: TypingIntensity) {
        guard !isContextMenuOpen else { return }

        let wasTyping = isTyping

        isTyping = true
        typingIntensity = intensity
        lastKeyboardEventAt = Date()

        if !wasTyping {
            typingStartedAt = Date()
        }

        animationState = .typing(intensity: intensity)
    }

    func setIdle() {
        guard !isContextMenuOpen else { return }

        isTyping = false
        typingIntensity = .inactive
        typingStartedAt = nil
        animationState = .idle

        hideTypingBubble()
    }

    func showTypingBubble(_ text: String) {
        guard !isContextMenuOpen else { return }

        typingBubbleText = text
        shouldShowTypingBubble = true
    }

    func hideTypingBubble() {
        typingBubbleText = nil
        shouldShowTypingBubble = false
    }

    func showReminderBubble(_ text: String) {
        reminderBubbleText = text
        shouldShowReminderBubble = true
    }

    func showReminder(_ reminder: MiloReminder) {
        activeReminder = reminder
        reminderBubbleText = reminder.message
        shouldShowReminderBubble = true
    }

    func hideReminderBubble() {
        hideReminder()
    }
    
    // MARK: - Todo Bubble

    func showTodoOverdueBubble(_ todo: MiloTodo) {
        activeTodoBubble = todo
        shouldShowTodoBubble = true
    }

    func hideTodoBubble() {
        activeTodoBubble = nil
        shouldShowTodoBubble = false
    }

    func hideReminder() {
        activeReminder = nil
        reminderBubbleText = nil
        shouldShowReminderBubble = false
    }
}
