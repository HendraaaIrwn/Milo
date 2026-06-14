//
//  MiloLocalStorageService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation
import OSLog

final class MiloLocalStorageService {
    static let shared = MiloLocalStorageService()

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let logger = Logger(
        subsystem: "com.milo",
        category: "LocalStorage"
    )

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func save<T: Codable>(_ value: T, forKey key: String) {
        do {
            let data = try encoder.encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to save data for key \(key): \(error.localizedDescription)")
        }
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String, defaultValue: T) -> T {
        guard let data = userDefaults.data(forKey: key) else {
            return defaultValue
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            logger.error("Failed to load data for key \(key): \(error.localizedDescription)")
            return defaultValue
        }
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
