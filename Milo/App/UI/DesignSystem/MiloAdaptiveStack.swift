import SwiftUI

struct MiloAdaptiveStack<Content: View>: View {
    let width: CGFloat
    let threshold: CGFloat
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: Content

    init(
        width: CGFloat,
        threshold: CGFloat = 560,
        spacing: CGFloat = 12,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.threshold = threshold
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        if width < threshold {
            VStack(alignment: alignment, spacing: spacing) { content }
        } else {
            HStack(alignment: .top, spacing: spacing) { content }
        }
    }
}
