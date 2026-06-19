//
//  WakaTimeConnectionStatusMiniView.swift
//  Milo
//

import SwiftUI

struct WakaTimeConnectionStatusMiniView: View {
    @StateObject private var store = WakaTimeConnectionStore.shared

    var body: some View {
        HStack(spacing: 10) {
            WakaTimeConnectionStatusBadge(status: store.status)
            Spacer()
            if store.hasSavedAPIKey && !store.isTesting {
                Button("Test") { store.testConnection() }
                    .buttonStyle(.plain).miloFont(.caption).foregroundStyle(.blue)
            }
        }
        .onAppear {
            store.refreshSavedKeyState()
            store.autoTestIfKeyExists()
        }
    }
}