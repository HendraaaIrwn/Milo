//
//  EmptyWatchedProjectsView.swift
//  Milo
//

import SwiftUI

struct EmptyWatchedProjectsView: View {
    let onAddProject: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(spacing: 4) {
                Text("No project folders yet")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text("Add a project folder so MILO can detect real-time coding activity.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button { onAddProject() } label: {
                Label("Add Project Folder", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.secondary.opacity(0.25))
        )
    }
}
