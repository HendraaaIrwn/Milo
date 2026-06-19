import AppKit
import SwiftUI

enum MiloOverlayDynamicTypeSizing {
    static func preferredBadgeSize() -> NSSize {
        let dynamicTypeSize = MiloMacDynamicTypeObserver.currentDynamicTypeSize()

        if dynamicTypeSize.isAccessibilitySize {
            return NSSize(width: 270, height: 60)
        }

        switch dynamicTypeSize {
        case .xLarge, .xxLarge:
            return NSSize(width: 230, height: 50)
        default:
            return NSSize(width: 220, height: 48)
        }
    }

    static func preferredBubbleSize() -> NSSize {
        let dynamicTypeSize = MiloMacDynamicTypeObserver.currentDynamicTypeSize()

        if dynamicTypeSize.isAccessibilitySize {
            return NSSize(width: 480, height: 200)
        }

        switch dynamicTypeSize {
        case .xLarge, .xxLarge:
            return NSSize(width: 420, height: 160)
        default:
            return NSSize(width: 360, height: 140)
        }
    }
}
