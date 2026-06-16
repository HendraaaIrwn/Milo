import SwiftUI

struct MiloStatusPillView: View {
    enum Tone {
        case success
        case warning
        case danger
        case neutral
        case info
    }

    let title: String
    var systemImage: String?
    var tone: Tone = .neutral

    var body: some View {
        HStack(spacing: 7) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
            }

            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .allowsTightening(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(color.opacity(0.14))
        .foregroundStyle(color)
        .clipShape(Capsule())
        .fixedSize(horizontal: true, vertical: false)
    }

    private var color: Color {
        switch tone {
        case .success:
            return .green
        case .warning:
            return .orange
        case .danger:
            return .red
        case .neutral:
            return .secondary
        case .info:
            return .blue
        }
    }
}
