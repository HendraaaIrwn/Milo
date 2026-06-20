//
//  SparkleUpdaterController.swift
//  Milo
//

import Sparkle

@MainActor
final class SparkleUpdaterController: NSObject {
    let updaterController: SPUStandardUpdaterController

    override init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        super.init()
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
