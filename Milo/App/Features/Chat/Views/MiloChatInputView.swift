//
//  MiloChatInputView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct MiloChatInputView: View {
    let onSubmit: @MainActor (String) -> Void
    let onCancel: @MainActor () -> Void

    @State private var text = ""

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Chat Reminder and Todo")
                .font(.title2.weight(.semibold))
            
            VStack(alignment: .leading) {
                Text("Try:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("remind me in 30 min to take a break")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("remind todo deploy jam 7 am")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("Type reminder", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(submit)
            }
            
            HStack {
                Spacer()

                Button("Cancel") {
                    onCancel()
                }

                Button("Save") {
                    submit()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSubmit)
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
    }
}
