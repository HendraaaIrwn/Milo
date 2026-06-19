//
//  PrivacySettingsView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import AppKit
import SwiftUI

/// PRIVACY: MILO only detects keyboard activity timing to animate typing.
/// MILO never reads, stores, or uploads what you type.
struct PrivacySettingsView: View {
    private var metrics = MiloScaledMetrics()

    @State private var hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
    @AppStorage(MiloSettingsKeys.typingBubbleDialogs) private var typingBubbleDialogs = true

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            heroCard
            keyboardActivityCard
            dataCards
            codingMetricsCard
            permissionCard
        }
        .onAppear {
            hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
        }
    }

    private var heroCard: some View {
        MiloPanelCardView(
            title: "Privacy",
            subtitle: "MILO stays local-first and avoids storing sensitive content.",
            trailing: AnyView(
                MiloStatusPill(
                    "Local-first",
                    color: .green,
                    systemImage: "lock.shield.fill"
                )
            )
        ) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: metrics.cardPadding) {
                    privacyMark
                    privacyIntro
                }

                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    privacyMark
                    privacyIntro
                }
            }
        }
    }

    private var privacyMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.22), Color.yellow.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                        .stroke(Color.green.opacity(0.22), lineWidth: 1)
                )

            Image(systemName: "lock.shield.fill")
                .font(.system(size: metrics.largeIconSize + 10, weight: .semibold))
                .foregroundStyle(.green)
        }
        .frame(width: 72, height: 72)
    }

    private var privacyIntro: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            Text("MILO does not read what you type.")
                .font(.title3.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)

            Text("Typing reactions use activity timing only. Coding metrics use project metadata and Git summaries only. Source code content, typed characters, and clipboard data are not stored.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var keyboardActivityCard: some View {
        MiloPanelCardView(
            title: "Keyboard Activity",
            subtitle: "Used only to animate typing reactions.",
            trailing: AnyView(
                MiloStatusPill(
                    typingBubbleDialogs ? "Enabled" : "Off",
                    color: typingBubbleDialogs ? .green : .secondary,
                    systemImage: typingBubbleDialogs ? "sparkles" : "moon"
                )
            )
        ) {
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                MiloSettingsRow(
                    title: "Typing Bubble Dialogs",
                    subtitle: "Show small local reactions based on typing rhythm and intensity."
                ) {
                    Toggle("", isOn: $typingBubbleDialogs)
                        .labelsHidden()
                }

                Text("Typing bubbles use intensity and timing only. MILO does not know what you typed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var dataCards: some View {
        LazyVGrid(columns: dataColumns, alignment: .leading, spacing: metrics.mediumSpacing) {
            dataCard(
                title: "Data Stored",
                subtitle: "Small local signals MILO needs.",
                systemImage: "checkmark.shield.fill",
                color: .green,
                items: [
                    "Last keyboard event timestamp",
                    "Typing intensity: inactive, slow, normal, fast",
                    "Active or inactive state"
                ]
            )

            dataCard(
                title: "Not Stored",
                subtitle: "Sensitive content MILO avoids.",
                systemImage: "xmark.shield.fill",
                color: .orange,
                items: [
                    "Typed characters or key values",
                    "Source code or clipboard content",
                    "Keyboard history or per-key logs",
                    "App or window focus information"
                ]
            )
        }
    }

    private var codingMetricsCard: some View {
        MiloPanelCardView(
            title: "Coding Metrics",
            subtitle: "Local activity metadata for dashboards and weekly summaries."
        ) {
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                Text("MILO tracks active editor, approximate project folder, language estimation from file extensions, and Git LOC summaries. Source code content is never read or stored.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: dataColumns, alignment: .leading, spacing: metrics.smallSpacing) {
                    privacyChip("Active app/editor name", systemImage: "macwindow")
                    privacyChip("User-selected project folder path", systemImage: "folder")
                    privacyChip("File extensions for language estimation", systemImage: "doc.text")
                    privacyChip("Git shortstat and numstat summaries", systemImage: "plus.forwardslash.minus")
                    privacyChip("Session duration and LOC summary", systemImage: "timer")
                }
            }
        }
    }

    private var permissionCard: some View {
        MiloPanelCardView(
            title: "Input Monitoring Permission",
            subtitle: "Needed for global typing detection.",
            trailing: AnyView(permissionStatus)
        ) {
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                Text("Global typing detection needs Input Monitoring permission. MILO still runs without it, but can only use local keyboard monitoring when available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                    Button("Request Permission") {
                        KeyboardActivityPermission.requestInputMonitoringAccess()
                        KeyboardActivityPermission.requestAccessibilityAccessIfNeeded()
                        refreshPermissionSoon()
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.primary))

                    Button("Open Accessibility") {
                        openSystemSettings("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))

                    Button("Open Input Monitoring") {
                        openSystemSettings("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                }
            }
        }
    }

    private var permissionStatus: some View {
        MiloStatusPill(
            hasKeyboardPermission ? "Permission granted" : "Permission needed",
            color: hasKeyboardPermission ? .green : .orange,
            systemImage: hasKeyboardPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
        )
    }

    private var dataColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 240), spacing: metrics.mediumSpacing)]
    }

    private func dataCard(
        title: String,
        subtitle: String,
        systemImage: String,
        color: Color,
        items: [String]
    ) -> some View {
        MiloPanelCardView(
            title: title,
            subtitle: subtitle,
            trailing: AnyView(
                Image(systemName: systemImage)
                    .font(.system(size: metrics.iconSize, weight: .semibold))
                    .foregroundStyle(color)
            )
        ) {
            VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                ForEach(items, id: \.self) { item in
                    bullet(item, color: color)
                }
            }
        }
    }

    private func privacyChip(_ text: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: metrics.smallSpacing) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)
                .frame(width: metrics.iconSize, alignment: .center)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(metrics.mediumSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.10))
        )
    }

    private func bullet(_ text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: metrics.smallSpacing) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5, weight: .bold))
                .foregroundStyle(color)
                .padding(.top, 6)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func openSystemSettings(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func refreshPermissionSoon() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            hasKeyboardPermission = KeyboardActivityPermission.canMonitorGlobalKeyboard
        }
    }
}

#if DEBUG
#Preview {
    PrivacySettingsView()
        .frame(minWidth: 640, idealWidth: 760, maxWidth: 980, minHeight: 520, idealHeight: 680, maxHeight: 900)
        .miloPanelDynamicTypeLimit()
}
#endif
