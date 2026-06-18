//
//  MiloAgentDebugLogger.swift
//  Milo
//
//  PRIVACY: DEBUG-only logger for agent detection diagnostics.
//  Only safe, non-sensitive metadata is logged (process names, agent types, status).
//  Never logs command arguments, terminal output, source code, file paths, or build logs.
//

import Foundation
import os

enum MiloAgentDebugLogger {
    private static let logger = Logger(subsystem: "com.hendrairawan.dev.Milo.agent", category: "AgentDetection")

    static func log(_ message: String) {
        #if DEBUG
        logger.debug("\(message, privacy: .public)")
        #endif
    }
}
