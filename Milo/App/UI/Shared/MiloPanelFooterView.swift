import SwiftUI

struct MiloPanelFooterView: View {
    private var metrics = MiloScaledMetrics()

    let message: String
    var statusTitle: String?
    var statusTone: MiloStatusPillView.Tone = .neutral

    init(
        message: String,
        statusTitle: String? = nil,
        statusTone: MiloStatusPillView.Tone = .neutral
    ) {
        self.message = message
        self.statusTitle = statusTitle
        self.statusTone = statusTone
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            footerHorizontal
            footerVertical
        }
        .padding(.horizontal, metrics.panelPadding)
        .padding(.vertical, metrics.bubblePaddingVertical)
        .background(.regularMaterial)
    }

    private var footerHorizontal: some View {
        HStack(spacing: metrics.mediumSpacing) {
            messageText
            Spacer(minLength: metrics.smallSpacing)
            statusPill
        }
    }

    private var footerVertical: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            messageText
            statusPill
        }
    }

    private var messageText: some View {
        Text(message)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)
    }

    @ViewBuilder
    private var statusPill: some View {
        if let statusTitle {
            MiloStatusPillView(
                title: statusTitle,
                tone: statusTone
            )
            .layoutPriority(2)
        }
    }
}
