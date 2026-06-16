import SwiftUI

struct MiloPanelHeaderView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var primaryActionTitle: String?
    var primaryActionSystemImage: String?
    var primaryAction: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.22))

                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 48, height: 48)
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(2)

            if let primaryActionTitle, let primaryAction {
                Button {
                    primaryAction()
                } label: {
                    if let primaryActionSystemImage {
                        Label(primaryActionTitle, systemImage: primaryActionSystemImage)
                    } else {
                        Text(primaryActionTitle)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .layoutPriority(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.regularMaterial)
    }
}
