//
//  MiloClaudeEventBubbleQueueConfig.swift
//  Milo
//
//  Tunables for the Claude hook event bubble queue.
//  The minimum gap and queue cap are spec values, not heuristics.
//

import Foundation

enum MiloClaudeEventBubbleQueueConfig {
    /// Minimum gap between event bubbles, in seconds.
    static let minimumGapSeconds: TimeInterval = 0.75

    /// Maximum number of pending event bubbles before overflow aggregation kicks in.
    static let maxQueueSize: Int = 12
}
