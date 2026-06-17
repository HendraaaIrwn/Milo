//
//  MiloFloatingPetView.swift
//  Milo
//

import Combine
import SwiftUI

@MainActor
final class MiloFloatingPetState: ObservableObject {
    @Published var mood: MiloMood = .idle
    @Published var reactionText: String?
    @Published var reactionSource: MiloBubbleSource = .click

    private var bubbleHideTask: Task<Void, Never>?

    deinit {
        bubbleHideTask?.cancel()
    }

    func showBubble(_ text: String, source: MiloBubbleSource = .click, hideAfter seconds: UInt64 = 3) {
        bubbleHideTask?.cancel()
        reactionText = text
        reactionSource = source
        MiloMumbleEngine.shared.speak(text)

        bubbleHideTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.reactionText = nil
            }
        }
    }

    func clearBubble() {
        bubbleHideTask?.cancel()
        bubbleHideTask = nil
        reactionText = nil
    }
}

struct MiloFloatingPetView: View {
    @ObservedObject var state: MiloFloatingPetState

    var body: some View {
        MiloRootView(
            mousePositionService: MousePositionService(),
            state: state,
            stateStore: MiloStateStore(),
            contextMenuController: nil,
            onLeftClick: {},
            characterFrame: { .zero }
        )
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloFloatingPetView(state: MiloFloatingPetState())
        .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
}
#endif
