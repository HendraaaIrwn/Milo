import SwiftUI

struct MiloStatusPillView: View {
    enum Tone {
        case success
        case warning
        case neutral
        case danger
        case info
    }

    private var metrics = MiloScaledMetrics()

    let title: String
    let systemImage: String
    let tone: Tone

    init(title: String, systemImage: String = "circle.fill", tone: Tone) {
        self.title = title
        self.systemImage = systemImage
        self.tone = tone
    }

    var body: some View {
        HStack(spacing: metrics.smallSpacing) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
            Text(title)
                .miloFont(.caption, weight: .semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, metrics.badgePaddingHorizontal)
        .padding(.vertical, metrics.badgePaddingVertical)
        .frame(minHeight: metrics.badgeMinHeight)
        .background(Capsule().fill(color.opacity(0.16)))
        .foregroundStyle(color)
    }

    private var color: Color {
        switch tone {
        case .success: return .green
        case .warning: return .orange
        case .neutral: return .secondary
        case .danger: return .red
        case .info: return .blue
        }
    }
}
