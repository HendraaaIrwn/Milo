//
//  MiloAgentDetectionSettingsStore.swift
//  Milo
//

import Foundation
import Combine

@MainActor
final class MiloAgentDetectionSettingsStore: ObservableObject {
    @Published var settings: MiloAgentDetectionSettings {
        didSet { save() }
    }

    private let key = "MiloAgentDetectionSettings.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(MiloAgentDetectionSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = MiloAgentDetectionSettings()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func reset() {
        settings = MiloAgentDetectionSettings()
    }
}
