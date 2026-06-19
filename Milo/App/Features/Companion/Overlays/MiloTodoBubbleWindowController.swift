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
             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
         } else {
             Color.clear.frame(width: 450, height: 180)
         }
     }
 }

 @MainActor
 final class MiloTodoBubbleWindowController {
     private var bubbleSize: NSSize {
         MiloMacDynamicTypeObserver.currentDynamicTypeSize().isAccessibilitySize
             ? NSSize(width: 610, height: 240)
             : NSSize(width: 450, height: 180)
     }
     private let bubbleState = MiloTodoBubbleState()
     private var latestCharacterFrame: NSRect = .zero
     private var dynamicTypeObservers: [NSObjectProtocol] = []

     private let overlay = MiloOverlayWindowController<AnyView>(
         defaultSize: NSSize(width: 450, height: 180),
         ignoresMouseEventsWhenVisible: false
     )

    func configure() {
        overlay.configure(
            rootView: AnyView(
                MiloTodoBubbleWrapperView(state: bubbleState)
            )
        )
        observeDynamicTypeChanges()
    }

    func show(
        todo: MiloTodo,
        relativeTo characterFrame: NSRect,
        duration: TimeInterval? = nil,
        onDone: @escaping () -> Void,
        onOpenTodoList: @escaping () -> Void
    ) {
        latestCharacterFrame = characterFrame
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
        latestCharacterFrame = characterFrame
        overlay.updatePosition(origin(relativeTo: characterFrame))
    }

    func destroy() {
        for observer in dynamicTypeObservers {
            NotificationCenter.default.removeObserver(observer)
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        dynamicTypeObservers.removeAll()
        overlay.destroy()
    }

    var isVisible: Bool { overlay.isVisible }

    private func origin(relativeTo characterFrame: NSRect) -> NSPoint {
        NSPoint(
            x: characterFrame.midX - bubbleSize.width / 2,
            y: characterFrame.maxY + 8
        )
    }

    private func observeDynamicTypeChanges() {
        guard dynamicTypeObservers.isEmpty else { return }

        dynamicTypeObservers.append(
            NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshDynamicTypeSize() }
            }
        )
        dynamicTypeObservers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshDynamicTypeSize() }
            }
        )
    }

    private func refreshDynamicTypeSize() {
        guard isVisible else { return }
        overlay.show(
            at: origin(relativeTo: latestCharacterFrame),
            size: bubbleSize,
            duration: nil
        )
    }
}
