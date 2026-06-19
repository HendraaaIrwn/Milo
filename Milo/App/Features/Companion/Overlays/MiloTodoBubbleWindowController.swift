//
//  MiloTodoBubbleWindowController.swift
//  Milo
//

import AppKit
import Combine
import SwiftUI

private final class MiloTodoBubbleState: ObservableObject {
    @Published var todo: MiloTodo?
    @Published var onDone: (() -> Void)?
    @Published var onOpenTodoList: (() -> Void)?

    func configure(
        todo: MiloTodo,
        onDone: @escaping () -> Void,
        onOpenTodoList: @escaping () -> Void
    ) {
        self.todo = todo
        self.onDone = onDone
        self.onOpenTodoList = onOpenTodoList
    }
}

private struct MiloTodoBubbleWrapperView: View {
    @ObservedObject var state: MiloTodoBubbleState

    var body: some View {
        if let todo = state.todo,
           let onDone = state.onDone,
           let onOpenTodoList = state.onOpenTodoList
        {
             MiloTodoBubbleView(
                 todo: todo,
                 onDone: onDone,
                 onOpenTodoList: onOpenTodoList
             )
             .environment(\.controlActiveState, .active)
             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
         } else {
             Color.clear.frame(width: 420, height: 170)
         }
     }
 }

 @MainActor
 final class MiloTodoBubbleWindowController {
     private let bubbleSize = NSSize(width: 420, height: 170)
     private let bubbleState = MiloTodoBubbleState()

     private let overlay = MiloOverlayWindowController<AnyView>(
         defaultSize: NSSize(width: 420, height: 170),
         ignoresMouseEventsWhenVisible: false
     )

    func configure() {
        overlay.configure(
            rootView: AnyView(
                MiloTodoBubbleWrapperView(state: bubbleState)
            )
        )
    }

    func show(
        todo: MiloTodo,
        relativeTo characterFrame: NSRect,
        duration: TimeInterval? = nil,
        onDone: @escaping () -> Void,
        onOpenTodoList: @escaping () -> Void
    ) {
        bubbleState.configure(
            todo: todo,
            onDone: onDone,
            onOpenTodoList: onOpenTodoList
        )
        overlay.show(
            at: origin(relativeTo: characterFrame),
            size: bubbleSize,
            duration: duration
        )
    }

    func hide() {
        overlay.hide()
    }

    func updatePosition(relativeTo characterFrame: NSRect) {
        overlay.updatePosition(origin(relativeTo: characterFrame))
    }

    func destroy() {
        overlay.destroy()
    }

    var isVisible: Bool { overlay.isVisible }

    private func origin(relativeTo characterFrame: NSRect) -> NSPoint {
        NSPoint(
            x: characterFrame.midX - bubbleSize.width / 2,
            y: characterFrame.maxY - 52
        )
    }
}
