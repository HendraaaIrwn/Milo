//
//  MiloRootView.swift
//  Milo
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = MiloLayout.designWidth
    static let windowHeight: CGFloat = MiloLayout.designHeight

    @ObservedObject var mousePositionService: MousePositionService
    @ObservedObject var state: MiloFloatingPetState
    @ObservedObject var stateStore: MiloStateStore
    let contextMenuController: MiloContextMenuController?
    let onLeftClick: () -> Void

    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true

    var characterFrame: () -> NSRect

    var body: some View {
        ZStack {
            MiloCharacter(
                mood: state.mood,
                mouseLocation: eyeFollowCursor && !stateStore.isContextMenuOpen
                    ? mousePositionService.mouseLocation
                    : nil,
                characterFrame: characterFrame()
            )
            .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
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
        .onChange(of: eyeFollowCursor) { _, enabled in
            if !enabled { }
        }
    }
}

#if DEBUG
#Preview {
    MiloRootView(
        mousePositionService: MousePositionService(),
        state: MiloFloatingPetState(),
        stateStore: MiloStateStore(),
        contextMenuController: nil,
        onLeftClick: {},
        characterFrame: { .zero }
    )
}
#endif
