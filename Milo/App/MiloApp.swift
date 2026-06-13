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
        MenuBarExtra("Milo", systemImage: "pawprint.circle") {
            Button("Show Milo") {
                appDelegate.showMilo()
            }

            Button("Hide Milo") {
                appDelegate.hideMilo()
            }

            Divider()

            Button("Start Pomodoro") {
                appDelegate.startPomodoro()
            }

            Button("Add Reminder") {
                appDelegate.addReminder()
            }

            Divider()

            Button("Quit") {
                appDelegate.quit()
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
