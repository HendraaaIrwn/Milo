//
//  WatchedProjectRowView.swift
//  Milo
//

import SwiftUI
import AppKit

struct WatchedProjectRowView: View {
    let project: WatchedProject

    let onToggle: (Bool) -> Void
    let onOpenInFinder: () -> Void
    let onRemove: () -> Void

    @State private var isEnabled: Bool

    init(
        project: WatchedProject,
        onToggle: @escaping (Bool) -> Void,
        onOpenInFinder: @escaping () -> Void,
        onRemove: @escaping () -> Void
    ) {
        self.project = project
        self.onToggle = onToggle
        self.onOpenInFinder = onOpenInFinder
        self.onRemove = onRemove
        _isEnabled = State(initialValue: project.isEnabled)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .onChange(of: isEnabled) { _, newValue in onToggle(newValue) }

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isEnabled ? Color.yellow.opacity(0.18) : Color.gray.opacity(0.12))
                Image(systemName: "folder.fill")
                    .foregroundStyle(isEnabled ? .orange : .secondary)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(project.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(1)

                    Text(isEnabled ? "Enabled" : "Disabled")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(isEnabled ? Color.green.opacity(0.14) : Color.gray.opacity(0.14))
                        .foregroundStyle(isEnabled ? .green : .secondary)
                        .clipShape(Capsule())
                }

                Text(project.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 8) {
                    if let lastActivityAt = project.lastActivityAt {
                        Label(lastActivityAt.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                    } else {
                        Label("No activity yet", systemImage: "clock")
                    }
                    if let language = project.lastKnownTopLanguage {
                        Label(language, systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            Menu {
                Button("Open in Finder") { onOpenInFinder() }
                Divider()
                Button("Remove", role: .destructive) { onRemove() }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
            }
            .menuStyle(.borderlessButton)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        )
    }
}
