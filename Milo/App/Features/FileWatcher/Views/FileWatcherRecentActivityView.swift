//
//  FileWatcherRecentActivityView.swift
//  Milo
//
//  PRIVACY: Shows only file metadata (relative path, event type, language). File contents are never read or stored.
//

import SwiftUI

struct FileWatcherRecentActivityView: View {
    let snapshot: ProjectActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                if let lastActivityAt = snapshot.lastActivityAt {
                    Text(lastActivityAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if snapshot.recentEvents.isEmpty {
                Text("No recent file activity yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
            } else {
                VStack(spacing: 6) {
                    ForEach(snapshot.recentEvents.suffix(6)) { event in
                        HStack(spacing: 8) {
                            Image(systemName: icon(for: event.eventType))
                                .foregroundStyle(color(for: event.eventType))
                                .frame(width: 18)

                            Text(event.relativePath)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer()

                            if let language = event.language {
                                Text(language)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    private func icon(for type: ProjectFileEventType) -> String {
        switch type {
        case .created: return "plus.circle.fill"
        case .modified: return "pencil.circle.fill"
        case .deleted: return "minus.circle.fill"
        case .renamed: return "arrow.triangle.2.circlepath.circle.fill"
        case .unknown: return "doc.circle.fill"
        }
    }

    private func color(for type: ProjectFileEventType) -> Color {
        switch type {
        case .created: return .green
        case .modified: return .orange
        case .deleted: return .red
        case .renamed: return .blue
        case .unknown: return .secondary
        }
    }
}
