import SwiftUI

struct MiloDynamicTypeProbeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var scaledBoxSize: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dynamic Type: \(String(describing: dynamicTypeSize))")
                .miloFont(.body)

            Text("Semantic body text should scale")
                .miloFont(.body)

            Text("Semantic caption text should scale")
                .miloFont(.caption)

            Text("Semantic callout text should scale")
                .miloFont(.callout)

            Text("Scaled metric box: \(Int(scaledBoxSize))")
                .miloFont(.caption)

            Rectangle()
                .frame(width: scaledBoxSize, height: scaledBoxSize)
        }
        .padding()
    }
}