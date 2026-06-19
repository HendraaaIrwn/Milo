//
//  EmptyWatchedProjectsView.swift
//  Milo
//

import SwiftUI

struct EmptyWatchedProjectsView: View {
    private var metrics = MiloScaledMetrics()

    let onAddProject: () -> Void

    init(onAddProject: @escaping () -> Void) {
        self.onAddProject = onAddProject
    }

    var body: some View {
        VStack(spacing: metrics.cardPadding) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: metrics.largeIconSize + 12, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(spacing: metrics.tinySpacing) {
                Text("No project folders yet")
                    .font(.headline.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                Text("Add a project folder so MILO can detect real-time coding activity.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button { onAddProject() } label: {
                Label("Add Project Folder", systemImage: "plus")
            }
            .buttonStyle(MiloAdaptiveButtonStyle(.primary))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, metrics.extraLargeSpacing)
        .padding(.horizontal, metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.secondary.opacity(0.25))
        )
    }
}
