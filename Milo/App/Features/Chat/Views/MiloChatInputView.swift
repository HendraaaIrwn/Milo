//
//  MiloChatInputView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct MiloChatInputView: View {
    private var metrics = MiloScaledMetrics()

    let onSubmit: @MainActor (String) -> Void
    let onCancel: @MainActor () -> Void

    init(
        onSubmit: @escaping @MainActor (String) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    @State private var text = ""

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.cardPadding) {
            Text("Chat Reminder and Todo")
                .miloFont(.title2, weight: .semibold)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: metrics.tinySpacing) {
                Text("Try:")
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                Text("remind me in 30 min to take a break")
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text("buat todo reminder untuk deploy jam 7 am")
                    .miloFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                TextField("Type reminder", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(submit)
            }
            
            MiloAdaptiveActionRow {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.secondary))

                Button("Save") {
                    submit()
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                .keyboardShortcut(.defaultAction)
                .disabled(!canSubmit)
            }
        }
        .padding(metrics.panelPadding)
        .frame(minWidth: 360, idealWidth: 420, maxWidth: 560, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .miloPanelDynamicTypeLimit()
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
    }
}