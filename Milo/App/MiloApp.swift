//
//  MiloApp.swift
//  Milo
//
//  Created by Hendra Irawan on 10/06/26.
//

import SwiftUI

@main
struct MiloApp: App {
    @NSApplicationDelegateAdaptor(MiloAppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
