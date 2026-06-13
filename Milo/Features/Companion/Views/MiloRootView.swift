//
//  MiloRootView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = 240
    static let windowHeight: CGFloat = 180

    @ObservedObject var state: MiloFloatingPetState
    @ObservedObject var stateStore: MiloStateStore
    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @State private var mouseLocation: CGPoint?
    @State private var characterFrame: CGRect = MiloRootView.defaultCharacterFrame

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear

            MiloCharacter(
                mood: state.mood,
                mouseLocation: eyeFollowCursor ? mouseLocation : nil,
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

            if let bubbleText {
                MiloReactionBubbleView(text: bubbleText)
                    .offset(y: -MiloLayout.designHeight - 10)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
                    .zIndex(10)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: Self.windowWidth, height: Self.windowHeight)
        .coordinateSpace(name: "miloRoot")
        .background(Color.clear)
        .onPreferenceChange(MiloRootFramePreferenceKey.self) { frame in
            guard !frame.isEmpty else { return }
            characterFrame = frame
        }
        .onChange(of: eyeFollowCursor) { _, enabled in
            if !enabled {
                mouseLocation = nil
            }
        }
        #if os(macOS)
        .overlay {
            TrackingMouseView(
                onMove: { mouseLocation = $0 },
                onExit: { mouseLocation = nil }
            )
            .frame(width: Self.windowWidth, height: Self.windowHeight)
        }
        #endif
    }

    private static var defaultCharacterFrame: CGRect {
        CGRect(
            x: (windowWidth - MiloLayout.designWidth) * 0.5,
            y: windowHeight - MiloLayout.designHeight,
            width: MiloLayout.designWidth,
            height: MiloLayout.designHeight
        )
    }

    private var bubbleText: String? {
        if stateStore.shouldShowTypingBubble, let typingBubbleText = stateStore.typingBubbleText {
            return typingBubbleText
        }

        return state.reactionText
    }

    private func showRandomReaction() {
        let text = MiloReactionLineProvider.randomLine(excluding: state.reactionText)
        state.showBubble(text)
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
    MiloRootView(state: MiloFloatingPetState(), stateStore: MiloStateStore())
}
#endif
