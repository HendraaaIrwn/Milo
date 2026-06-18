//
//  MiloMenuInteractionState.swift
//  Milo
//

import Foundation

@MainActor
final class MiloMenuInteractionState {
    static let shared = MiloMenuInteractionState()

    private(set) var isMenuTracking = false

    func menuWillOpen() { isMenuTracking = true }
    func menuDidClose() { isMenuTracking = false }
}
