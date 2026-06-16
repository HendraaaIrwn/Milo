import SwiftUI

struct MiloPanelFooterView: View {
    let message: String
    var statusTitle: String?
    var statusTone: MiloStatusPillView.Tone = .neutral

    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            Spacer(minLength: 8)

            if let statusTitle {
                MiloStatusPillView(
                    title: statusTitle,
                    tone: statusTone
                )
                .layoutPriority(2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
}
