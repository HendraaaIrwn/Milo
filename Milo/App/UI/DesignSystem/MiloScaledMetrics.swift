import SwiftUI

struct MiloScaledMetrics {
    @ScaledMetric(relativeTo: .caption) var tinySpacing: CGFloat = 4
    @ScaledMetric(relativeTo: .body) var smallSpacing: CGFloat = 6
    @ScaledMetric(relativeTo: .body) var mediumSpacing: CGFloat = 10
    @ScaledMetric(relativeTo: .body) var largeSpacing: CGFloat = 16
    @ScaledMetric(relativeTo: .body) var extraLargeSpacing: CGFloat = 24

    @ScaledMetric(relativeTo: .body) var cardPadding: CGFloat = 14
    @ScaledMetric(relativeTo: .body) var panelPadding: CGFloat = 24

    @ScaledMetric(relativeTo: .body) var bubblePaddingHorizontal: CGFloat = 16
    @ScaledMetric(relativeTo: .body) var bubblePaddingVertical: CGFloat = 12

    @ScaledMetric(relativeTo: .caption) var badgePaddingHorizontal: CGFloat = 12
    @ScaledMetric(relativeTo: .caption) var badgePaddingVertical: CGFloat = 7
    @ScaledMetric(relativeTo: .caption) var badgeIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .caption) var badgeMinHeight: CGFloat = 34

    @ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) var largeIconSize: CGFloat = 26

    @ScaledMetric(relativeTo: .body) var buttonHorizontalPadding: CGFloat = 14
    @ScaledMetric(relativeTo: .body) var buttonVerticalPadding: CGFloat = 8
    @ScaledMetric(relativeTo: .body) var buttonMinHeight: CGFloat = 36

    @ScaledMetric(relativeTo: .body) var cornerRadius: CGFloat = 16
    @ScaledMetric(relativeTo: .body) var smallCornerRadius: CGFloat = 10
    @ScaledMetric(relativeTo: .body) var capsuleHeight: CGFloat = 32
}
