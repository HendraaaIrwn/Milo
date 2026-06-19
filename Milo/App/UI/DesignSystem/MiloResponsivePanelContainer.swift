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
        idealWidth: CGFloat = 760,
        maxWidth: CGFloat = 980,
        minHeight: CGFloat = 520,
        idealHeight: CGFloat = 700,
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
                .padding(panelPadding(for: dynamicTypeSize))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(
            minWidth: minWidth,
            idealWidth: adjustedIdealWidth(for: dynamicTypeSize),
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: adjustedIdealHeight(for: dynamicTypeSize),
            maxHeight: maxHeight
        )
        .miloPanelDynamicTypeLimit()
    }

    private func panelPadding(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 28 : 24
    }

    private func adjustedIdealWidth(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? max(idealWidth, 820) : idealWidth
    }

    private func adjustedIdealHeight(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? max(idealHeight, 760) : idealHeight
    }
}
