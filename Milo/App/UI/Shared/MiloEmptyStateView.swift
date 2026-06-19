import SwiftUI

struct MiloEmptyStateView: View {
    private var metrics = MiloScaledMetrics()

    let systemImage: String
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonSystemImage: String?
    var action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonSystemImage: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonSystemImage = buttonSystemImage
        self.action = action
    }

    var body: some View {
        VStack(spacing: metrics.cardPadding) {
            Image(systemName: systemImage)
                .font(.system(size: metrics.largeIconSize + 14, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(spacing: metrics.smallSpacing) {
                Text(title)
                    .miloFont(.headline, weight: .bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(message)
                    .miloFont(.body, weight: .medium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 460)
            }

            if let buttonTitle, let action {
                Button {
                    action()
                } label: {
                    if let buttonSystemImage {
                        Label(buttonTitle, systemImage: buttonSystemImage)
                    } else {
                        Text(buttonTitle)
                    }
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.primary))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, metrics.extraLargeSpacing)
        .padding(.horizontal, metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7]))
                .foregroundStyle(Color.secondary.opacity(0.25))
        )
    }
}
