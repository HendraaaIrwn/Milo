//
//  MiloPersonalitySettingsView.swift
//  Milo
//

import SwiftUI

struct MiloPersonalitySettingsView: View {
    private var metrics = MiloScaledMetrics()

    @ObservedObject var settingsStore: MiloPersonalitySettingsStore
    @ObservedObject var availabilityService: AppleIntelligenceAvailabilityService

    let onTestResponse: () async -> String?

    @State private var testResponse: String?
    @State private var isTesting = false

    init(
        settingsStore: MiloPersonalitySettingsStore,
        availabilityService: AppleIntelligenceAvailabilityService,
        onTestResponse: @escaping () async -> String?
    ) {
        self.settingsStore = settingsStore
        self.availabilityService = availabilityService
        self.onTestResponse = onTestResponse
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                headerSection
                responseModeSection

                if settingsStore.settings.responseMode == .smartPersonality {
                    smartPersonalitySection
                    privacySection
                    testSection
                }
            }
            .padding(metrics.panelPadding)
        }
        .task { await availabilityService.refresh() }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text("MILO Personality")
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
            Text("Choose how MILO talks while you code.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var responseModeSection: some View {
        MiloPanelCardView(title: "Response Mode") {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            Picker("Response Mode", selection: $settingsStore.settings.responseMode) {
                ForEach(MiloResponseMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Text(settingsStore.settings.responseMode.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        }
    }

    private var smartPersonalitySection: some View {
        MiloPanelCardView(title: "Smart Personality", subtitle: "Apple Intelligence availability and response style.") {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                MiloStatusPill(availabilityLabel, color: availabilityColor, systemImage: "sparkles")

                Button {
                    Task { await availabilityService.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.subtle))
            }

            Toggle("Enable Apple Intelligence responses", isOn: $settingsStore.settings.smartPersonalityEnabled)
                .disabled(availabilityService.status != .available)

            if settingsStore.settings.smartPersonalityEnabled {
                Divider()

                Picker("Tone", selection: $settingsStore.settings.tone) {
                    Text("Friendly").tag(MiloPersonalityTone.friendly)
                    Text("Playful").tag(MiloPersonalityTone.playful)
                    Text("Tiny Roast").tag(MiloPersonalityTone.tinyRoast)
                    Text("Calm").tag(MiloPersonalityTone.calm)
                    Text("Focus Coach").tag(MiloPersonalityTone.focusCoach)
                }
                .pickerStyle(.menu)

                Stepper("Max response words: \(settingsStore.settings.maxResponseWords)",
                        value: $settingsStore.settings.maxResponseWords, in: 8...28)

                Toggle("Allow playful roast mode", isOn: $settingsStore.settings.allowPlayfulRoast)
            }
        }
        }
    }

    private var privacySection: some View {
        MiloPanelCardView(title: "Privacy") {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            Text("MILO only uses safe coding metadata like focus time, language, Pomodoro state, and todo counts. It never reads typed text, source code, clipboard, passwords, or file contents.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                Toggle("Use project name in responses", isOn: $settingsStore.settings.allowProjectName)
                Toggle("Use active language in responses", isOn: $settingsStore.settings.allowActiveLanguage)
                Toggle("Use coding duration in responses", isOn: $settingsStore.settings.allowCodingDuration)
                Toggle("Use typing intensity in responses", isOn: $settingsStore.settings.allowTypingIntensity)
                Toggle("Use todo/reminder counts in responses", isOn: $settingsStore.settings.allowTodoCounts)
                Toggle("Use Pomodoro state in responses", isOn: $settingsStore.settings.allowPomodoroState)
            }
            .font(.caption)
            .disabled(!settingsStore.settings.smartPersonalityEnabled)
        }
        }
    }

    private var testSection: some View {
        MiloPanelCardView(title: "Test Response", subtitle: "Preview without saving a full conversation transcript.") {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                Button {
                    Task {
                        isTesting = true
                        testResponse = await onTestResponse()
                        isTesting = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        if isTesting {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        Text("Test Smart Personality")
                    }
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                .disabled(isTesting)
                .disabled(!settingsStore.settings.smartPersonalityEnabled)
            }

            if let testResponse {
                Text("milo> \(testResponse)")
                    .font(.body.monospaced().weight(.medium))
                    .foregroundStyle(.green)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(metrics.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                            .fill(Color.black.opacity(0.88))
                            .overlay(
                                RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                                    .stroke(Color.green.opacity(0.25), lineWidth: 1)
                            )
                    )
            }
        }
        }
    }

    private var availabilityLabel: String {
        switch availabilityService.status {
        case .available:              return "Apple Intelligence available"
        case .frameworkUnavailable:   return "Foundation Models unavailable"
        case .osUnsupported:          return "Unsupported macOS version"
        case .appleIntelligenceDisabled: return "Apple Intelligence off"
        case .unknown:                return "Checking..."
        }
    }

    private var availabilityColor: Color {
        availabilityService.status == .available ? .green : .orange
    }
}

#if DEBUG
#Preview("MILO Personality - Medium") {
    MiloPersonalitySettingsView(
        settingsStore: MiloPersonalitySettingsStore(),
        availabilityService: AppleIntelligenceAvailabilityService(),
        onTestResponse: { "This is a test response from MILO." }
    )
    .dynamicTypeSize(.medium)
}

#Preview("MILO Personality - Accessibility 2") {
    MiloPersonalitySettingsView(
        settingsStore: MiloPersonalitySettingsStore(),
        availabilityService: AppleIntelligenceAvailabilityService(),
        onTestResponse: { "This is a test response from MILO." }
    )
    .dynamicTypeSize(.accessibility2)
}
#endif
