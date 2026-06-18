import SwiftUI

struct MiloMetricCardView: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let value: String
    var systemImage: String?

    init(title: String, value: String, systemImage: String? = nil) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            HStack(alignment: .top, spacing: metrics.smallSpacing) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: metrics.iconSize, weight: .semibold))
                        .foregroundStyle(.orange)
                }

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.75)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(metrics.cardPadding)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.72))
        )
    }
}
