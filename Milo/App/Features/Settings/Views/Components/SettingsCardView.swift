//
//  SettingsCardView.swift
//  Milo
//

import SwiftUI

struct SettingsCardView<Content: View>: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let subtitle: String?
    let systemImage: String?
    let content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.cardPadding) {
            HStack(alignment: .top, spacing: metrics.mediumSpacing) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: metrics.iconSize, weight: .semibold))
                        .foregroundStyle(.orange)
                        .frame(width: metrics.largeIconSize)
                }
                VStack(alignment: .leading, spacing: metrics.tinySpacing) {
                    Text(title)
                        .miloFont(.bodyBold)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle {
                        Text(subtitle)
                            .miloFont(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            content()
                .miloFont(.body)
        }
        .padding(metrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}
