import SwiftUI

struct MiloAdaptiveButtonStyle: ButtonStyle {
    enum Variant {
        case primary
        case secondary
        case destructive
        case subtle
    }

    @ScaledMetric(relativeTo: .body) private var horizontalPadding: CGFloat = 14
    @ScaledMetric(relativeTo: .body) private var verticalPadding: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var cornerRadius: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 36

    let variant: Variant

    init(_ variant: Variant = .secondary) {
        self.variant = variant
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: minHeight)
            .background(background(configuration: configuration))
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }

    private func background(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(backgroundColor.opacity(configuration.isPressed ? 0.72 : 1))
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: return .orange
        case .secondary: return .white.opacity(0.14)
        case .destructive: return .red.opacity(0.85)
        case .subtle: return .white.opacity(0.08)
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary: return .black
        case .secondary, .destructive, .subtle: return .white
        }
    }
}
