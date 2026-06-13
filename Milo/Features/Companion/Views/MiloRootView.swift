//
//  MiloRootView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = 220
    static let windowHeight: CGFloat = 180

    @ObservedObject var state: MiloFloatingPetState

    @State private var mouseLocation: CGPoint?
    @State private var characterFrame: CGRect = .zero
    @State private var reactionText: String?
    @State private var bubbleHideTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear

            MiloCharacter(
                mood: state.mood,
                mouseLocation: mouseLocation,
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
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
                        showRandomReaction()
                    }
                }
            )

            if let reactionText {
                MiloReactionBubbleView(text: reactionText)
                    .offset(y: -MiloLayout.designHeight - 10)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
                    .zIndex(10)
            }
        }
        .frame(width: Self.windowWidth, height: Self.windowHeight)
        .coordinateSpace(name: "miloRoot")
        .background(Color.clear)
        .onPreferenceChange(MiloRootFramePreferenceKey.self) { frame in
            characterFrame = frame
        }
        .onDisappear {
            bubbleHideTask?.cancel()
            bubbleHideTask = nil
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

    private func showRandomReaction() {
        bubbleHideTask?.cancel()
        reactionText = MiloReactionLineProvider.randomLine(excluding: reactionText)

        bubbleHideTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.18)) {
                    reactionText = nil
                }
            }
        }
    }
}

private struct MiloRootFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#Preview {
    MiloRootView(state: MiloFloatingPetState())
}
