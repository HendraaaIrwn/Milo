import SwiftUI

struct MiloCodeSnippetBlock: View {
    private var metrics = MiloScaledMetrics()
    let code: String

    var body: some View {
        ScrollView(.horizontal) {
            Text(code)
                .miloFont(.monospacedCaption)
                .textSelection(.enabled)
                .padding(metrics.cardPadding)
        }
        .background(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.32))
        )
        .overlay(
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
