//
//  CodingMetricsSettingsEmbedView.swift
//  Milo
//

import SwiftUI

struct CodingMetricsSettingsEmbedView: View {
    let coordinator: CodingMetricsCoordinator?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(title: "Local Metrics", subtitle: "Track your coding activity locally.", systemImage: "chart.bar") {
                if let coordinator {
                    let s = coordinator.localMetricsService.snapshot
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Coding today: \(s.codingSecondsToday / 60)m").font(.caption)
                        Text("Top language: \(s.topLanguage ?? "-")").font(.caption)
                        Text("Top editor: \(s.topEditor ?? "-")").font(.caption)
                        Spacer()
                        Spacer()
                        Button("Reset Local Stats", role: .destructive) {
                            coordinator.localMetricsService.resetLocalStats()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
        }
    }
}
