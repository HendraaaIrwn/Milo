//
//  ActiveAppDetector.swift
//  Milo
//
//  PRIVACY: MILO reads only the frontmost application's localized name and bundle identifier. No window contents.
//

import AppKit

struct ActiveAppInfo: Equatable {
    let name: String
    let bundleIdentifier: String?
}

struct ActiveAppDetector {
    static func currentApp() -> ActiveAppInfo? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        return ActiveAppInfo(
            name: app.localizedName ?? "Unknown",
            bundleIdentifier: app.bundleIdentifier
        )
    }

    static func isCodingEditor(_ app: ActiveAppInfo) -> Bool {
        let bundle = app.bundleIdentifier?.lowercased() ?? ""
        let name = app.name.lowercased()

        let knownEditors = [
            "com.apple.dt.xcode",
            "com.microsoft.vscode",
            "com.todesktop.230313mzl4w4u92",
            "com.cursor.cursor",
            "com.jetbrains.intellij",
            "com.jetbrains.webstorm",
            "com.jetbrains.pycharm",
            "com.jetbrains.clion",
            "com.jetbrains.goland",
            "com.jetbrains.rider",
            "com.jetbrains.phpstorm",
            "com.jetbrains.ruby",
            "com.sublimetext.4",
            "com.github.atom",
            "com.googlecode.iterm2",
            "com.apple.terminal",
            "dev.warp.Warp-Stable",
            "co.zeit.hyper",
            "com.ghostty.ghostty"
        ]

        if knownEditors.contains(bundle) {
            return true
        }

        let knownNames = [
            "xcode",
            "visual studio code",
            "vscode",
            "cursor",
            "intellij",
            "webstorm",
            "pycharm",
            "clion",
            "goland",
            "rider",
            "phpstorm",
            "rubymine",
            "terminal",
            "iterm",
            "warp",
            "hyper",
            "ghostty"
        ]

        return knownNames.contains { name.contains($0) }
    }
}
