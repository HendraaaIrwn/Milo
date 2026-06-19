import SwiftUI

struct MiloStatusPill: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let color: Color
    let systemImage: String?

    init(
        _ title: String,
        color: Color,
        systemImage: String? = nil
    ) {
        self.title = title
        self.color = color
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: metrics.smallSpacing) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
            }

            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, metrics.badgePaddingHorizontal)
        .padding(.vertical, metrics.badgePaddingVertical)
        .background(Capsule().fill(color.opacity(0.16)))
        .foregroundStyle(color)
    }
}
