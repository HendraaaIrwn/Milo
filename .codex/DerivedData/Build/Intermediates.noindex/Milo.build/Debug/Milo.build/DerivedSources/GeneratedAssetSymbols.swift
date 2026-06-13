import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Body" asset catalog image resource.
    static let body = DeveloperToolsSupport.ImageResource(name: "Body", bundle: resourceBundle)

    /// The "CloseLeftEye" asset catalog image resource.
    static let closeLeftEye = DeveloperToolsSupport.ImageResource(name: "CloseLeftEye", bundle: resourceBundle)

    /// The "CloseRightEye" asset catalog image resource.
    static let closeRightEye = DeveloperToolsSupport.ImageResource(name: "CloseRightEye", bundle: resourceBundle)

    /// The "CommandLine" asset catalog image resource.
    static let commandLine = DeveloperToolsSupport.ImageResource(name: "CommandLine", bundle: resourceBundle)

    /// The "Mouth" asset catalog image resource.
    static let mouth = DeveloperToolsSupport.ImageResource(name: "Mouth", bundle: resourceBundle)

    /// The "halfCloseLeftEye" asset catalog image resource.
    static let halfCloseLeftEye = DeveloperToolsSupport.ImageResource(name: "halfCloseLeftEye", bundle: resourceBundle)

    /// The "halfCloseRightEye" asset catalog image resource.
    static let halfCloseRightEye = DeveloperToolsSupport.ImageResource(name: "halfCloseRightEye", bundle: resourceBundle)

    /// The "leftEye" asset catalog image resource.
    static let leftEye = DeveloperToolsSupport.ImageResource(name: "leftEye", bundle: resourceBundle)

    /// The "leftPupil" asset catalog image resource.
    static let leftPupil = DeveloperToolsSupport.ImageResource(name: "leftPupil", bundle: resourceBundle)

    /// The "rightEye" asset catalog image resource.
    static let rightEye = DeveloperToolsSupport.ImageResource(name: "rightEye", bundle: resourceBundle)

    /// The "rightPupil" asset catalog image resource.
    static let rightPupil = DeveloperToolsSupport.ImageResource(name: "rightPupil", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Body" asset catalog image.
    static var body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .body)
#else
        .init()
#endif
    }

    /// The "CloseLeftEye" asset catalog image.
    static var closeLeftEye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .closeLeftEye)
#else
        .init()
#endif
    }

    /// The "CloseRightEye" asset catalog image.
    static var closeRightEye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .closeRightEye)
#else
        .init()
#endif
    }

    /// The "CommandLine" asset catalog image.
    static var commandLine: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .commandLine)
#else
        .init()
#endif
    }

    /// The "Mouth" asset catalog image.
    static var mouth: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mouth)
#else
        .init()
#endif
    }

    /// The "halfCloseLeftEye" asset catalog image.
    static var halfCloseLeftEye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .halfCloseLeftEye)
#else
        .init()
#endif
    }

    /// The "halfCloseRightEye" asset catalog image.
    static var halfCloseRightEye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .halfCloseRightEye)
#else
        .init()
#endif
    }

    /// The "leftEye" asset catalog image.
    static var leftEye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .leftEye)
#else
        .init()
#endif
    }

    /// The "leftPupil" asset catalog image.
    static var leftPupil: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .leftPupil)
#else
        .init()
#endif
    }

    /// The "rightEye" asset catalog image.
    static var rightEye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rightEye)
#else
        .init()
#endif
    }

    /// The "rightPupil" asset catalog image.
    static var rightPupil: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rightPupil)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Body" asset catalog image.
    static var body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .body)
#else
        .init()
#endif
    }

    /// The "CloseLeftEye" asset catalog image.
    static var closeLeftEye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .closeLeftEye)
#else
        .init()
#endif
    }

    /// The "CloseRightEye" asset catalog image.
    static var closeRightEye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .closeRightEye)
#else
        .init()
#endif
    }

    /// The "CommandLine" asset catalog image.
    static var commandLine: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .commandLine)
#else
        .init()
#endif
    }

    /// The "Mouth" asset catalog image.
    static var mouth: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mouth)
#else
        .init()
#endif
    }

    /// The "halfCloseLeftEye" asset catalog image.
    static var halfCloseLeftEye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .halfCloseLeftEye)
#else
        .init()
#endif
    }

    /// The "halfCloseRightEye" asset catalog image.
    static var halfCloseRightEye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .halfCloseRightEye)
#else
        .init()
#endif
    }

    /// The "leftEye" asset catalog image.
    static var leftEye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .leftEye)
#else
        .init()
#endif
    }

    /// The "leftPupil" asset catalog image.
    static var leftPupil: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .leftPupil)
#else
        .init()
#endif
    }

    /// The "rightEye" asset catalog image.
    static var rightEye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rightEye)
#else
        .init()
#endif
    }

    /// The "rightPupil" asset catalog image.
    static var rightPupil: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rightPupil)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

