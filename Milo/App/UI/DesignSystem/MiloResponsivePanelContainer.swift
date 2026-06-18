import SwiftUI

struct MiloResponsivePanelContainer<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let minWidth: CGFloat
    private let idealWidth: CGFloat
    private let maxWidth: CGFloat
    private let minHeight: CGFloat
    private let idealHeight: CGFloat
    private let maxHeight: CGFloat
    private let content: Content

    init(
        minWidth: CGFloat = 560,
        idealWidth: CGFloat = 720,
        maxWidth: CGFloat = 980,
        minHeight: CGFloat = 520,
        idealHeight: CGFloat = 680,
        maxHeight: CGFloat = 900,
        @ViewBuilder content: () -> Content
    ) {
        self.minWidth = minWidth
        self.idealWidth = idealWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.idealHeight = idealHeight
        self.maxHeight = maxHeight
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .padding(dynamicTypeSize.isAccessibilitySize ? 28 : 24)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(
            minWidth: minWidth,
            idealWidth: dynamicTypeSize.isAccessibilitySize ? max(idealWidth, 780) : idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: dynamicTypeSize.isAccessibilitySize ? max(idealHeight, 760) : idealHeight,
            maxHeight: maxHeight
        )
        .miloPanelDynamicTypeLimit()
    }
}
