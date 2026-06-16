//
//  MiloRootView.swift
//  Milo
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = MiloLayout.designWidth
    static let windowHeight: CGFloat = MiloLayout.designHeight

    @ObservedObject var state: MiloFloatingPetState
    @ObservedObject var stateStore: MiloStateStore
    let contextMenuController: MiloContextMenuController?
    let onLeftClick: () -> Void

    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @State private var mouseLocation: CGPoint?
    @State private var characterFrame: CGRect = .zero

    var body: some View {
        ZStack {
            MiloCharacter(
                mood: state.mood,
                mouseLocation: eyeFollowCursor && !stateStore.isContextMenuOpen ? mouseLocation : nil,
                characterFrame: characterFrame
            )
            .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: MiloRootFramePreferenceKey.self,
                        value: proxy.frame(in: .named("miloRoot"))
                    )
                }
            }
            .allowsHitTesting(false)

            if let contextMenuController {
                MiloRightClickMenuRepresentable(
                    contextMenuController: contextMenuController,
                    onLeftClick: onLeftClick
                )
                .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
            }
        }
        .frame(width: Self.windowWidth, height: Self.windowHeight)
        .coordinateSpace(name: "miloRoot")
        .onPreferenceChange(MiloRootFramePreferenceKey.self) { frame in
            guard !frame.isEmpty else { return }
            #if DEBUG
            if characterFrame == .zero {
                print("[MiloRootView] characterFrame set: \(frame)")
            }
            #endif
            characterFrame = frame
        }
        #if os(macOS)
        .overlay {
            TrackingMouseView(
                onMove: { point in
                    guard !stateStore.isContextMenuOpen else { return }
                    #if DEBUG
                    if mouseLocation == nil {
                        print("[MiloRootView] first mouseLocation: \(point), eyeFollowCursor=\(eyeFollowCursor), characterFrame=\(characterFrame)")
                    }
                    #endif
                    mouseLocation = point
                },
                onExit: {
                    guard !stateStore.isContextMenuOpen else { return }
                    mouseLocation = nil
                }
            )
            .frame(width: Self.windowWidth, height: Self.windowHeight)
        }
        #endif
        .onChange(of: eyeFollowCursor) { _, enabled in
            if !enabled { mouseLocation = nil }
        }
    }
}

private struct MiloRootFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloRootView(
        state: MiloFloatingPetState(),
        stateStore: MiloStateStore(),
        contextMenuController: nil,
        onLeftClick: {}
    )
}
#endif
