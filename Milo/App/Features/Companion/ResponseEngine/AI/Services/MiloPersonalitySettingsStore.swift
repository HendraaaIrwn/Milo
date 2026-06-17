//
//  MiloPersonalitySettingsStore.swift
//  Milo
//

import Foundation
import Combine
@MainActor
final class MiloPersonalitySettingsStore: ObservableObject {
    @Published var settings: MiloPersonalitySettings {
        didSet { save() }
    }

    private let key = "MiloPersonalitySettings.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(MiloPersonalitySettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = MiloPersonalitySettings()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func reset() {
        settings = MiloPersonalitySettings()
    }
}
