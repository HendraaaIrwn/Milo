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

    private var bubbleHideTask: Task<Void, Never>?

    deinit {
        bubbleHideTask?.cancel()
    }

    func showBubble(_ text: String, hideAfter seconds: UInt64 = 3) {
        bubbleHideTask?.cancel()
        reactionText = text
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
            mood: state.mood,
            mouseLocation: nil,
            characterFrame: CGRect(x: 0, y: 0, width: 160, height: 110),
            contextMenuController: nil,
            onLeftClick: {}
        )
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloFloatingPetView(state: MiloFloatingPetState())
        .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
}
#endif
