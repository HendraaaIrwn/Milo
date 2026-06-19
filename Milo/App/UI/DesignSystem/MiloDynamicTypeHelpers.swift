import SwiftUI

extension DynamicTypeSize {
    var miloIsLarge: Bool { self >= .xLarge }
    var miloIsVeryLarge: Bool { self >= .xxLarge }
    var miloIsAccessibility: Bool { isAccessibilitySize }
}

struct MiloDynamicTypeClampModifier: ViewModifier {
    let range: ClosedRange<DynamicTypeSize>

    func body(content: Content) -> some View {
        content.dynamicTypeSize(range)
    }
}

extension View {
    func miloSmallOverlayDynamicTypeLimit() -> some View {
        modifier(MiloDynamicTypeClampModifier(range: .small ... .accessibility5))
    }

    func miloBubbleDynamicTypeLimit() -> some View {
        modifier(MiloDynamicTypeClampModifier(range: .small ... .accessibility5))
    }

    func miloPanelDynamicTypeLimit() -> some View {
        modifier(MiloDynamicTypeClampModifier(range: .xSmall ... .accessibility5))
    }
}
