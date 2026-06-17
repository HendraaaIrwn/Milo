//
//  MiloResponseDebugLogger.swift
//  Milo
//

import Foundation

struct MiloResponseDebugLogger {
    static var isEnabled = true

    static func log(_ message: String) {
        guard isEnabled else { return }
        print("[MILO ResponseEngine]", message)
    }
}
