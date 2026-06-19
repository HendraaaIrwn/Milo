//
//  AboutSettingsView.swift
//  Milo
//

import SwiftUI

struct AboutSettingsView: View {
    private var metrics = MiloScaledMetrics()

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            heroCard
            quickFactsCard
            privacyDesignCard
        }
    }

    private var heroCard: some View {
        MiloPanelCardView(
            title: "MILO",
            subtitle: "Tiny coding companion for macOS."
        ) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: metrics.cardPadding) {
                    appMark
                    appText
                    Spacer(minLength: metrics.smallSpacing)
                    versionPill
                }

                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    HStack(alignment: .center, spacing: metrics.cardPadding) {
                        appMark
                        appText
                    }
                    versionPill
                }
            }
        }
    }

    private var appMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.34), Color.orange.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                        .stroke(Color.orange.opacity(0.22), lineWidth: 1)
                )

            Text("M")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.orange)
        }
        .frame(width: 68, height: 68)
    }

    private var appText: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text("MILO")
                .font(.title2.weight(.black).monospaced())
                .fixedSize(horizontal: false, vertical: true)

            Text("Floating desktop helper for reminders, Pomodoro, coding metrics, and local agent signals.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var versionPill: some View {
        MiloStatusPill(
            "Version \(appVersion)",
            color: .orange,
            systemImage: "shippingbox.fill"
        )
    }

    private var quickFactsCard: some View {
        MiloPanelCardView(
            title: "Built For Focus",
            subtitle: "Small utilities that stay close to your coding flow."
        ) {
            LazyVGrid(columns: factColumns, alignment: .leading, spacing: metrics.mediumSpacing) {
                factTile("SwiftUI + AppKit", value: "Native macOS", systemImage: "macwindow")
                factTile("Local Metrics", value: "On device", systemImage: "chart.bar.xaxis")
                factTile("Reminders", value: "Tiny popups", systemImage: "bell.badge")
                factTile("Pomodoro", value: "Focus timer", systemImage: "timer")
            }
        }
    }

    private var privacyDesignCard: some View {
        MiloPanelCardView(
            title: "Privacy & Design",
            subtitle: "Local-first, compact, and privacy-friendly."
        ) {
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                privacyRow("No cloud, no login, no telemetry.", systemImage: "checkmark.shield.fill")
                privacyRow("Local storage via UserDefaults + Keychain.", systemImage: "key.fill")
                privacyRow("Keyboard tracking stores timing only, not content.", systemImage: "keyboard")
                privacyRow("Coding metrics store metadata, not source code.", systemImage: "lock.doc.fill")
            }
        }
    }

    private var factColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: metrics.mediumSpacing)]
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func factTile(_ title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            Image(systemName: systemImage)
                .font(.system(size: metrics.iconSize, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: metrics.tinySpacing) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text(value)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(metrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.10))
        )
    }

    private func privacyRow(_ text: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: metrics.mediumSpacing) {
            Image(systemName: systemImage)
                .font(.system(size: metrics.iconSize, weight: .semibold))
                .foregroundStyle(.green)
                .frame(width: metrics.largeIconSize, alignment: .center)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, metrics.tinySpacing)
    }
}
