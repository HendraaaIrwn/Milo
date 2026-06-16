//
//  SecurityScopedBookmarkStore.swift
//  Milo
//
//  PRIVACY: Security-scoped bookmarks allow MILO to access user-selected folders
//  after app restart, even with App Sandbox enabled.
//

import Foundation
import AppKit

final class SecurityScopedBookmarkStore {
    static let shared = SecurityScopedBookmarkStore()

    private init() {}

    func createBookmark(for url: URL) throws -> Data {
        try url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }

    func resolveBookmark(_ data: Data) throws -> URL {
        var isStale = false

        let url = try URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )

        return url
    }
}
