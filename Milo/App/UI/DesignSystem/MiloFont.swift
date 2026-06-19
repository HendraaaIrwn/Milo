import SwiftUI

enum MiloTextStyle: CaseIterable {
    case body
    case bodyBold
    case callout
    case caption
    case captionBold
    case caption2
    case headline
    case subheadline
    case title2
    case title3
    case largeTitle
    case roundedBody
    case roundedCallout
    case roundedCaption2
    case roundedTitle3
    case monospacedCaption
    case monospacedCallout
}

extension MiloTextStyle {
    var baseSize: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title2: return 22
        case .title3, .roundedTitle3: return 20
        case .headline: return 15
        case .body, .bodyBold, .roundedBody: return 14
        case .callout, .roundedCallout: return 13
        case .subheadline: return 12
        case .caption, .captionBold, .roundedCaption2, .monospacedCaption: return 11
        case .caption2: return 10
        case .monospacedCallout: return 13
        }
    }
}

struct MiloFontModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let style: MiloTextStyle
    var weight: Font.Weight?

    func body(content: Content) -> some View {
        let baseSize = style.baseSize
        let scale = scaleFactor(for: dynamicTypeSize)
        let adjusted = baseSize * scale

        var font: Font
        switch style {
        case .roundedBody, .roundedCallout, .roundedCaption2, .roundedTitle3:
            font = .system(size: adjusted, design: .rounded)
        case .monospacedCaption:
            font = .system(size: adjusted, design: .monospaced)
        case .monospacedCallout:
            font = .system(size: adjusted, design: .monospaced)
        default:
            font = .system(size: adjusted)
        }

        if let weight = weight {
            font = font.weight(weight)
        }
        return content.font(font)
    }

    private func scaleFactor(for size: DynamicTypeSize) -> CGFloat {
        switch size {
        case .xSmall: return 0.85
        case .small: return 0.92
        case .medium: return 1.0
        case .large: return 1.07
        case .xLarge: return 1.15
        case .xxLarge: return 1.23
        case .xxxLarge: return 1.3
        case .accessibility1: return 1.35
        case .accessibility2: return 1.5
        case .accessibility3: return 1.65
        case .accessibility4: return 1.8
        case .accessibility5: return 2.0
        @unknown default: return 1.0
        }
    }
}

extension View {
    func miloFont(_ style: MiloTextStyle) -> some View {
        modifier(MiloFontModifier(style: style))
    }

    func miloFont(_ style: MiloTextStyle, weight: Font.Weight) -> some View {
        modifier(MiloFontModifier(style: style, weight: weight))
    }
}
