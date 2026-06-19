//
//  WakaTimeSettingsView.swift
//  Milo
//

import SwiftUI

struct WakaTimeSettingsView: View {
    var body: some View {
        WakaTimeConnectionView()
    }
}

#if DEBUG
#Preview {
    WakaTimeSettingsView()
        .dynamicTypeSize(.medium)
}
#endif
