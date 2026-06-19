import SwiftUI

struct MiloPanelCardView<Content: View>: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let subtitle: String?
    let trailing: AnyView?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        trailing: AnyView? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            ViewThatFits(in: .horizontal) {
                headerHorizontal
                headerVertical
            }

            content
                .miloFont(.body)
        }
        .padding(metrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.92))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }

    private var headerHorizontal: some View {
        HStack(alignment: .top, spacing: metrics.mediumSpacing) {
            titleBlock
            Spacer(minLength: metrics.mediumSpacing)
            if let trailing { trailing.layoutPriority(2) }
        }
    }

    private var headerVertical: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            titleBlock
            if let trailing { trailing }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(title)
                .miloFont(.headline, weight: .bold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .miloFont(.caption, weight: .medium)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)
    }
}
