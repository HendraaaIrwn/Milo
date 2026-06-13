//
//  KeyboardActivityPermission.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import ApplicationServices
import Foundation

enum KeyboardActivityPermission {
    static var hasInputMonitoringAccess: Bool {
        CGPreflightListenEventAccess()
    }

    static var hasAccessibilityAccess: Bool {
        AXIsProcessTrusted()
    }

    static var canMonitorGlobalKeyboard: Bool {
        hasInputMonitoringAccess || hasAccessibilityAccess
    }

    @discardableResult
    static func requestInputMonitoringAccess() -> Bool {
        CGRequestListenEventAccess()
    }

    static func requestAccessibilityAccessIfNeeded() {
        guard !hasAccessibilityAccess else { return }

        let options: CFDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        AXIsProcessTrustedWithOptions(options)
    }
}
