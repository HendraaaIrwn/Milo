import AppKit
import Combine
import SwiftUI

enum MiloDebugDynamicTypeOption: String, CaseIterable, Identifiable {
    case system
    case medium
    case large
    case xLarge
    case xxLarge
    case accessibility1
    case accessibility2
    case accessibility3
    case accessibility4
    case accessibility5

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .medium: return "Medium"
        case .large: return "Large"
        case .xLarge: return "Extra Large"
        case .xxLarge: return "XX Large"
        case .accessibility1: return "Accessibility 1"
        case .accessibility2: return "Accessibility 2"
        case .accessibility3: return "Accessibility 3"
        case .accessibility4: return "Accessibility 4"
        case .accessibility5: return "Accessibility 5"
        }
    }

    var dynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .system: return nil
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .xLarge
        case .xxLarge: return .xxLarge
        case .accessibility1: return .accessibility1
        case .accessibility2: return .accessibility2
        case .accessibility3: return .accessibility3
        case .accessibility4: return .accessibility4
        case .accessibility5: return .accessibility5
        }
    }

    var contentSizeCategory: ContentSizeCategory? {
        switch self {
        case .system: return nil
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .extraLarge
        case .xxLarge: return .extraExtraLarge
        case .accessibility1: return .accessibilityMedium
        case .accessibility2: return .accessibilityLarge
        case .accessibility3: return .accessibilityExtraLarge
        case .accessibility4: return .accessibilityExtraExtraLarge
        case .accessibility5: return .accessibilityExtraExtraExtraLarge
        }
    }
}

@MainActor
final class MiloMacDynamicTypeObserver: ObservableObject {
    @Published private(set) var dynamicTypeSize: DynamicTypeSize = MiloMacDynamicTypeObserver.currentDynamicTypeSize()

    private var observers: [NSObjectProtocol] = []

    init() {
        let notificationCenter = NotificationCenter.default
        observers.append(
            notificationCenter.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            }
        )
        observers.append(
            notificationCenter.addObserver(
                forName: NSApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            }
        )
        observers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            }
        )
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    func refresh() {
        let nextSize = Self.currentDynamicTypeSize()
        guard nextSize != dynamicTypeSize else { return }
        dynamicTypeSize = nextSize
    }

    static func currentDynamicTypeSize() -> DynamicTypeSize {
        if let debugSize = currentDebugOption().dynamicTypeSize {
            return debugSize
        }
        return systemDynamicTypeSize()
    }

    static func currentContentSizeCategory() -> ContentSizeCategory {
        if let debugCategory = currentDebugOption().contentSizeCategory {
            return debugCategory
        }
        return contentSizeCategory(for: systemDynamicTypeSize())
    }

    private static func currentDebugOption() -> MiloDebugDynamicTypeOption {
        let rawValue = UserDefaults.standard.string(forKey: "milo.debug.dynamicTypeOption")
        return rawValue.flatMap(MiloDebugDynamicTypeOption.init(rawValue:)) ?? .system
    }

    private static func systemDynamicTypeSize() -> DynamicTypeSize {
        let pointSize = NSFont.preferredFont(forTextStyle: .body, options: [:]).pointSize

        switch pointSize {
        case ..<12.5: return .small
        case ..<13.5: return .medium
        case ..<14.5: return .large
        case ..<15.5: return .xLarge
        case ..<17.0: return .xxLarge
        case ..<18.0: return .xxxLarge
        case ..<19.0: return .accessibility1
        case ..<21.0: return .accessibility2
        case ..<23.0: return .accessibility3
        case ..<26.0: return .accessibility4
        default: return .accessibility5
        }
    }

    private static func contentSizeCategory(for dynamicTypeSize: DynamicTypeSize) -> ContentSizeCategory {
        switch dynamicTypeSize {
        case .xSmall: return .extraSmall
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .extraLarge
        case .xxLarge: return .extraExtraLarge
        case .xxxLarge: return .extraExtraExtraLarge
        case .accessibility1: return .accessibilityMedium
        case .accessibility2: return .accessibilityLarge
        case .accessibility3: return .accessibilityExtraLarge
        case .accessibility4: return .accessibilityExtraExtraLarge
        case .accessibility5: return .accessibilityExtraExtraExtraLarge
        @unknown default: return .large
        }
    }
}

struct MiloDynamicTypeDebugWrapper<Content: View>: View {
    @StateObject private var dynamicTypeObserver = MiloMacDynamicTypeObserver()

    @AppStorage("milo.debug.dynamicTypeOption")
    private var optionRawValue = MiloDebugDynamicTypeOption.system.rawValue

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let option = MiloDebugDynamicTypeOption(rawValue: optionRawValue) ?? .system
        let dynamicTypeSize = option.dynamicTypeSize ?? dynamicTypeObserver.dynamicTypeSize
        let contentSizeCategory = option.contentSizeCategory ?? MiloMacDynamicTypeObserver.currentContentSizeCategory()

        content
            .dynamicTypeSize(dynamicTypeSize)
            .environment(\.sizeCategory, contentSizeCategory)
    }
}

struct MiloDynamicTypeDebugPickerView: View {
    @AppStorage("milo.debug.dynamicTypeOption")
    private var optionRawValue: String = MiloDebugDynamicTypeOption.system.rawValue

    var body: some View {
        Picker("Dynamic Type Test", selection: $optionRawValue) {
            ForEach(MiloDebugDynamicTypeOption.allCases) { option in
                Text(option.title).tag(option.rawValue)
            }
        }
        .pickerStyle(.menu)
    }
}

enum MiloHostingRoot {
    @MainActor
    static func wrap<Content: View>(
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        MiloDynamicTypeDebugWrapper {
            content()
        }
    }
}
