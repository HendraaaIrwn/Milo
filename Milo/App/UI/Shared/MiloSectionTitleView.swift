import SwiftUI

struct MiloSectionTitleView: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .miloFont(.roundedTitle3, weight: .black)
                .foregroundStyle(.primary)

            if let subtitle {
                Text(subtitle)
                    .miloFont(.roundedCallout, weight: .medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
