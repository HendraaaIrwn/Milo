//
//  FileWatcherRecentActivityView.swift
//  Milo
//
//  PRIVACY: Shows only file metadata (relative path, event type, language). File contents are never read or stored.
//

import SwiftUI

struct FileWatcherRecentActivityView: View {
    private var metrics = MiloScaledMetrics()

    let snapshot: ProjectActivitySnapshot

    init(snapshot: ProjectActivitySnapshot) {
        self.snapshot = snapshot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: metrics.smallSpacing) {
                Text("Recent Activity")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if let lastActivityAt = snapshot.lastActivityAt {
                    Text(lastActivityAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: metrics.tinySpacing) {
                Text("Recent Activity")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                if let lastActivityAt = snapshot.lastActivityAt {
                    Text(lastActivityAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            }

            if snapshot.recentEvents.isEmpty {
                Text("No recent file activity yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, metrics.mediumSpacing)
            } else {
                VStack(spacing: metrics.smallSpacing) {
                    ForEach(snapshot.recentEvents.suffix(6)) { event in
                        HStack(alignment: .top, spacing: metrics.smallSpacing) {
                            Image(systemName: icon(for: event.eventType))
                                .foregroundStyle(color(for: event.eventType))
                                .frame(width: metrics.iconSize)

                            Text(event.relativePath)
                                .font(.caption)
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .fixedSize(horizontal: false, vertical: true)

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
        .padding(metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
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
