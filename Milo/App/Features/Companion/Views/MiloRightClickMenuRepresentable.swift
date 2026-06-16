//
//  MiloRightClickMenuRepresentable.swift
//  Milo
//

import AppKit
import SwiftUI

struct MiloRightClickMenuRepresentable: NSViewRepresentable {
    let contextMenuController: MiloContextMenuController
    let onLeftClick: () -> Void

    func makeNSView(context: Context) -> MiloRightClickHitView {
        let view = MiloRightClickHitView()
        view.contextMenuController = contextMenuController
        view.onLeftClick = onLeftClick
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }

    func updateNSView(_ nsView: MiloRightClickHitView, context: Context) {
        nsView.contextMenuController = contextMenuController
        nsView.onLeftClick = onLeftClick
    }
}
