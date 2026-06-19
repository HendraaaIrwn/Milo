import SwiftUI

struct MiloPanelHeaderView: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let subtitle: String
    let systemImage: String
    var primaryActionTitle: String?
    var primaryActionSystemImage: String?
    var primaryAction: (() -> Void)?

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        primaryActionTitle: String? = nil,
        primaryActionSystemImage: String? = nil,
        primaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.primaryActionTitle = primaryActionTitle
        self.primaryActionSystemImage = primaryActionSystemImage
        self.primaryAction = primaryAction
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            headerHorizontal
            headerVertical
        }
        .padding(.horizontal, metrics.largeSpacing)
        .padding(.vertical, metrics.cardPadding)
        .background(.regularMaterial)
    }

    private var headerHorizontal: some View {
        HStack(spacing: metrics.mediumSpacing) {
            icon
            titleBlock
            primaryActionButton
        }
    }

    private var headerVertical: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            HStack(spacing: metrics.mediumSpacing) {
                icon
                titleBlock
            }
            primaryActionButton
        }
    }

    private var icon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.22))

            Image(systemName: systemImage)
                .font(.system(size: metrics.largeIconSize, weight: .semibold))
                .foregroundStyle(.orange)
        }
        .frame(width: metrics.largeIconSize + 22, height: metrics.largeIconSize + 22)
        .layoutPriority(0)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(2)
    }

    @ViewBuilder
    private var primaryActionButton: some View {
        if let primaryActionTitle, let primaryAction {
            Button {
                primaryAction()
            } label: {
                if let primaryActionSystemImage {
                    Image(systemName: primaryActionSystemImage)
                        .font(.system(size: metrics.smallIconSize, weight: .semibold))
                        .frame(width: metrics.largeIconSize + 4 , height: metrics.largeIconSize + 4 )
                } else {
                    Text(primaryActionTitle)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: metrics.largeIconSize + 4, height: metrics.largeIconSize + 4)
                }
            }
            .buttonStyle(.plain)
            .background(
                Circle()
                    .fill(Color.orange)
            )
            .foregroundStyle(.black)
            .clipShape(Circle())
            .contentShape(Circle())
            .accessibilityLabel(primaryActionTitle)
            .help(primaryActionTitle)
            .layoutPriority(1)
            .padding(.trailing, 20)
        }
    }
}
