//
//  MiloAgentProcessSnapshot.swift
//  Milo
//
//  PRIVACY: In-memory only. Process snapshots are never persisted.
//  The command field is used only for detection and discarded after polling.
//

import Foundation

struct MiloAgentProcessSnapshot: Identifiable, Equatable {
    let id: Int32
    let pid: Int32
    let processName: String
    let command: String?
    let startedAt: Date?
}
