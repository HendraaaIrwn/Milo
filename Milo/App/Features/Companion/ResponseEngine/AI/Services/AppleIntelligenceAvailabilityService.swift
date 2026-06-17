//
//  AppleIntelligenceAvailabilityService.swift
//  Milo
//

import Foundation
import Combine

enum AppleIntelligenceAvailabilityStatus: Equatable {
    case available
    case frameworkUnavailable
    case osUnsupported
    case appleIntelligenceDisabled
    case unknown
}

@MainActor
final class AppleIntelligenceAvailabilityService: ObservableObject {
    @Published private(set) var status: AppleIntelligenceAvailabilityStatus = .unknown

    func refresh() async {
        #if canImport(FoundationModels)
        status = await checkFoundationModelAvailability()
        #else
        status = .frameworkUnavailable
        #endif
    }

    private func checkFoundationModelAvailability() async -> AppleIntelligenceAvailabilityStatus {
        #if canImport(FoundationModels)
        // TODO: Replace with actual FoundationModels API availability check when macOS 26 SDK ships.
        // Example:
        //   guard #available(macOS 26.0, *) else { return .osUnsupported }
        //   let model = SystemLanguageModel.default
        //   let available = await model.isAvailable
        //   return available ? .available : .appleIntelligenceDisabled
        return .osUnsupported
        #else
        return .frameworkUnavailable
        #endif
    }
}
