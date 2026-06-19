import SwiftUI

struct MiloPanelScaffoldView<Content: View>: View {
    private var metrics = MiloScaledMetrics()

    let title: String
    let subtitle: String
    let systemImage: String
    let primaryActionTitle: String?
    let primaryActionSystemImage: String?
    let primaryAction: (() -> Void)?
    let content: Content
    let footer: AnyView?

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        primaryActionTitle: String? = nil,
        primaryActionSystemImage: String? = nil,
        primaryAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.primaryActionTitle = primaryActionTitle
        self.primaryActionSystemImage = primaryActionSystemImage
        self.primaryAction = primaryAction
        self.content = content()
        self.footer = nil
    }

    init<Footer: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        primaryActionTitle: String? = nil,
        primaryActionSystemImage: String? = nil,
        primaryAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.primaryActionTitle = primaryActionTitle
        self.primaryActionSystemImage = primaryActionSystemImage
        self.primaryAction = primaryAction
        self.content = content()
        self.footer = AnyView(footer())
    }

    var body: some View {
        VStack(spacing: 0) {
            MiloPanelHeaderView(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                primaryActionTitle: primaryActionTitle,
                primaryActionSystemImage: primaryActionSystemImage,
                primaryAction: primaryAction
            )

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                    content
                }
                .padding(metrics.panelPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.windowBackgroundColor))

            if let footer {
                Divider()
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .miloPanelDynamicTypeLimit()
    }
}
