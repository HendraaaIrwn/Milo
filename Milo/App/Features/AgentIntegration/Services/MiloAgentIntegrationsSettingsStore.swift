//
//  MiloAgentIntegrationsSettingsStore.swift
//  Milo
//

import Foundation
import Combine

@MainActor
final class MiloAgentIntegrationsSettingsStore: ObservableObject {
    @Published var configs: [MiloAgentIntegrationConfig] {
        didSet { save() }
    }

    private let key = "MiloAgentIntegrationsSettings.v3"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MiloAgentIntegrationConfig].self, from: data) {
            self.configs = Self.mergeWithDefaults(decoded)
        } else {
            self.configs = Self.defaultConfigs
        }
    }

    static let defaultConfigs: [MiloAgentIntegrationConfig] = [
        MiloAgentIntegrationConfig(agentType: .codex),
        MiloAgentIntegrationConfig(agentType: .claudeCode),
        MiloAgentIntegrationConfig(agentType: .cursorAgent),
        MiloAgentIntegrationConfig(agentType: .xcodeBuild),
        MiloAgentIntegrationConfig(agentType: .genericTerminal)
    ]

    private static func mergeWithDefaults(_ saved: [MiloAgentIntegrationConfig]) -> [MiloAgentIntegrationConfig] {
        var result: [MiloAgentIntegrationConfig] = []
        for defaultConfig in defaultConfigs {
            if let existing = saved.first(where: { $0.agentType == defaultConfig.agentType }) {
                result.append(existing)
            } else {
                result.append(defaultConfig)
            }
        }
        return result
    }

    func config(for agentType: MiloAgentType) -> MiloAgentIntegrationConfig {
        configs.first(where: { $0.agentType == agentType }) ?? MiloAgentIntegrationConfig(agentType: agentType)
    }

    func update(_ config: MiloAgentIntegrationConfig) {
        if let index = configs.firstIndex(where: { $0.agentType == config.agentType }) {
            configs[index] = config
        } else {
            configs.append(config)
        }
    }

    func setStatus(_ status: MiloAgentConnectionStatus, for agentType: MiloAgentType, errorMessage: String? = nil) {
        var cfg = config(for: agentType)
        cfg.connectionStatus = status
        cfg.lastErrorMessage = errorMessage
        switch status {
        case .connected:
            cfg.isEnabled = true
            cfg.isConnected = true
            cfg.lastConnectedAt = Date()
        case .notConnected, .disconnected, .failed:
            cfg.isEnabled = false
            cfg.isConnected = false
        case .testPassed, .testFailed:
            cfg.lastTestedAt = Date()
        case .connecting, .testing:
            break
        }
        update(cfg)
    }

    func disconnect(_ agentType: MiloAgentType) {
        var cfg = config(for: agentType)
        cfg.isEnabled = false
        cfg.isConnected = false
        cfg.connectionStatus = .disconnected
        update(cfg)
    }

    func disconnectAll() {
        for var cfg in configs {
            cfg.isEnabled = false
            cfg.isConnected = false
            cfg.connectionStatus = .disconnected
            update(cfg)
        }
    }

    func resetAll() { configs = Self.defaultConfigs }

    private func save() {
        guard let data = try? JSONEncoder().encode(configs) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
