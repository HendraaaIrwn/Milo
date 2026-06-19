import SwiftUI

private struct MiloVisualFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        guard !next.isEmpty else { return }
        value = value.isEmpty ? next : value.union(next)
    }
}

extension View {
    func miloReportVisualFrame(onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: MiloVisualFramePreferenceKey.self,
                    value: proxy.frame(in: .named("MiloOverlayWindow"))
                )
            }
        )
        .onPreferenceChange(MiloVisualFramePreferenceKey.self) { rect in
            guard !rect.isEmpty else { return }
            onChange(rect)
        }
    }
}
