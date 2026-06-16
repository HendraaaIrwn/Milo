//
//  MiloRootView.swift
//  Milo
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = MiloLayout.designWidth
    static let windowHeight: CGFloat = MiloLayout.designHeight

    let mood: MiloMood
    let mouseLocation: CGPoint?
    let characterFrame: CGRect
    let contextMenuController: MiloContextMenuController?
    let onLeftClick: () -> Void

    var body: some View {
        ZStack {
            MiloCharacter(
                mood: mood,
                mouseLocation: mouseLocation,
                characterFrame: characterFrame
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
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloRootView(
        mood: .idle,
        mouseLocation: nil,
        characterFrame: CGRect(x: 0, y: 0, width: 160, height: 110),
        contextMenuController: nil,
        onLeftClick: {}
    )
}
#endif
