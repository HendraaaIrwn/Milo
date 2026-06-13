//
//  KeyboardActivityService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import AppKit
import Foundation

/// PRIVACY NOTICE:
/// MILO uses NSEvent monitors and a listen-only CGEvent tap to detect *when* keyboard activity happens.
/// - event.characters is NEVER accessed.
/// - key codes are NEVER stored as history.
/// - No typed text, source code, clipboard, or input content is read or saved.
/// - Only timing, event count, and derived intensity are used.
///
/// This service is fully local and offline. No data leaves the device.
@MainActor
final class KeyboardActivityService {
    private weak var miloStateStore: MiloStateStore?
    private let typingBubbleService: TypingBubbleService

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var eventTap: CFMachPort?
    private var eventTapRunLoopSource: CFRunLoopSource?
    private var eventTapObserver: NSObjectProtocol?
    private var idleTask: Task<Void, Never>?

    private var recentEventTimestamps: [Date] = []
    private var lastAcceptedEventAt: Date?
    private let duplicateEventThresholdSeconds: TimeInterval = 0.01
    private let recentWindowSeconds: TimeInterval = 1.2
    private let idleDelayNanoseconds: UInt64 = 2_000_000_000

    init(miloStateStore: MiloStateStore, typingBubbleService: TypingBubbleService) {
        self.miloStateStore = miloStateStore
        self.typingBubbleService = typingBubbleService
    }

    func start() {
        stop()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.keyDown]
        ) { [weak self] event in
            Task { @MainActor in
                self?.handleKeyboardActivity()
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown]
        ) { [weak self] event in
            Task { @MainActor in
                self?.handleKeyboardActivity()
            }
            return event
        }

        startListenOnlyEventTap()
    }

    func stop() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        if let eventTapObserver {
            NotificationCenter.default.removeObserver(eventTapObserver)
            self.eventTapObserver = nil
        }
        if let eventTapRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), eventTapRunLoopSource, .commonModes)
            self.eventTapRunLoopSource = nil
        }
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            self.eventTap = nil
        }
        idleTask?.cancel()
        idleTask = nil
    }

    var isRunning: Bool {
        globalMonitor != nil || eventTap != nil
    }

    private func startListenOnlyEventTap() {
        eventTapObserver = NotificationCenter.default.addObserver(
            forName: .miloKeyboardActivityDetected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.handleKeyboardActivity()
            }
        }

        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, _ in
            if type == .keyDown {
                NotificationCenter.default.post(name: .miloKeyboardActivityDetected, object: nil)
            }

            return Unmanaged.passUnretained(event)
        }

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: nil
        )

        guard let eventTap else { return }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        eventTapRunLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    private func handleKeyboardActivity() {
        // PRIVACY: Do NOT read event.characters.
        // Do NOT store key codes, typed text, or any input content.
        // MILO only tracks timing and typing intensity.

        let now = Date()
        if let lastAcceptedEventAt, now.timeIntervalSince(lastAcceptedEventAt) < duplicateEventThresholdSeconds {
            return
        }

        lastAcceptedEventAt = now
        recentEventTimestamps.append(now)

        recentEventTimestamps = recentEventTimestamps.filter {
            now.timeIntervalSince($0) <= recentWindowSeconds
        }

        let intensity = calculateIntensity(eventCount: recentEventTimestamps.count)
        miloStateStore?.setTyping(intensity: intensity)
        typingBubbleService.handleTypingActivity(intensity: intensity)
        scheduleReturnToIdle()
    }

    private func calculateIntensity(eventCount: Int) -> TypingIntensity {
        switch eventCount {
        case 0:     .inactive
        case 1...3: .slow
        case 4...8: .normal
        default:    .fast
        }
    }

    private func scheduleReturnToIdle() {
        idleTask?.cancel()

        idleTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.idleDelayNanoseconds ?? 2_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.typingBubbleService.handleTypingStopped()
                self?.miloStateStore?.setIdle()
                self?.recentEventTimestamps.removeAll()
                self?.lastAcceptedEventAt = nil
            }
        }
    }

    deinit {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        if let eventTapObserver {
            NotificationCenter.default.removeObserver(eventTapObserver)
        }
        if let eventTapRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), eventTapRunLoopSource, .commonModes)
        }
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        idleTask?.cancel()
    }
}

private extension Notification.Name {
    static let miloKeyboardActivityDetected = Notification.Name("miloKeyboardActivityDetected")
}
