//
//  CodingMetricsCoordinator.swift
//  Milo
//
//  PRIVACY: Combines local-only metrics with optional WakaTime enrichment. Local project data is never uploaded.
//

import Combine
import Foundation

@MainActor
final class CodingMetricsCoordinator: ObservableObject {
    @Published private(set) var wakaTimeSummary: WakaTimeSummary?
    @Published private(set) var sourceLabel: String = "Local"

    let localMetricsService: CodingMetricsService
    let weeklyMetricsService: WeeklyCodingMetricsService
    private let wakaTimeClient: WakaTimeClient

    private var refreshTask: Task<Void, Never>?

    init(
        localMetricsService: CodingMetricsService,
        weeklyMetricsService: WeeklyCodingMetricsService,
        wakaTimeClient: WakaTimeClient
    ) {
        self.localMetricsService = localMetricsService
        self.weeklyMetricsService = weeklyMetricsService
        self.wakaTimeClient = wakaTimeClient
    }

    func start() {
        localMetricsService.start()
        startWakaTimeRefreshIfEnabled()
    }

    func stop() {
        localMetricsService.stop()
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refreshWakaTime() {
        Task {
            do {
                let summary = try await wakaTimeClient.fetchTodaySummary()

                await MainActor.run {
                    self.wakaTimeSummary = summary
                    self.sourceLabel = summary == nil ? "Local" : "Local + WakaTime"
                }
            } catch {
                await MainActor.run {
                    self.wakaTimeSummary = nil
                    self.sourceLabel = "Local"
                }
            }
        }
    }

    private func startWakaTimeRefreshIfEnabled() {
        guard isWakaTimeEnabled else {
            sourceLabel = "Local"
            return
        }

        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                await MainActor.run {
                    self?.refreshWakaTime()
                }

                try? await Task.sleep(nanoseconds: 15 * 60 * 1_000_000_000)
            }
        }
    }

    private var isWakaTimeEnabled: Bool {
        UserDefaults.standard.bool(forKey: MiloStorageKeys.wakaTimeEnabled)
    }
}
