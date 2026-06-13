//
//  MiloFloatingPetView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct MiloFloatingPetView: View {
    @State private var mouseLocation: CGPoint?
    @State private var characterFrame: CGRect = .zero

    var body: some View {
        MiloCharacter(
            mood: .idle,
            mouseLocation: mouseLocation,
            characterFrame: characterFrame
        )
        .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: MiloFloatingPetFramePreferenceKey.self,
                    value: proxy.frame(in: .named("miloPet"))
                )
            }
        }
        .coordinateSpace(name: "miloPet")
        .background(Color.clear)
        .onPreferenceChange(MiloFloatingPetFramePreferenceKey.self) { frame in
            characterFrame = frame
        }
        #if os(macOS)
        .overlay {
            TrackingMouseView(
                onMove: { mouseLocation = $0 },
                onExit: { mouseLocation = nil }
            )
        }
        #endif
    }
}

private struct MiloFloatingPetFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#Preview {
    MiloFloatingPetView()
        .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
}
