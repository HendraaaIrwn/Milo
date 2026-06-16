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

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    WakaTimeSettingsView()
        .frame(width: 480, height: 520)
}
#endif
