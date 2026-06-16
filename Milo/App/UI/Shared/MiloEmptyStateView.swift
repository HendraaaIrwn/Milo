import SwiftUI

struct MiloEmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonSystemImage: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))

                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
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
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 42)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7]))
                .foregroundStyle(Color.secondary.opacity(0.25))
        )
    }
}
