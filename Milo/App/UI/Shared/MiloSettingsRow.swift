import SwiftUI

struct MiloSettingsRow<Content: View>: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let subtitle: String?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: metrics.mediumSpacing) {
                label
                Spacer(minLength: metrics.mediumSpacing)
                content
            }

            VStack(alignment: .leading, spacing: metrics.smallSpacing) {
                label
                content
            }
        }
        .miloFont(.body)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var label: some View {
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
        .layoutPriority(1)
    }
}
