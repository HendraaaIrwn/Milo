//
//  MiloRootView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = 340
    static let windowHeight: CGFloat = 240

    @ObservedObject var state: MiloFloatingPetState
    @ObservedObject var stateStore: MiloStateStore
    var onAddReminder: () -> Void = {}
    var onChatReminder: () -> Void = {}
    var onHideMilo: () -> Void = {}
    var onReminderDone: (MiloReminder) -> Void = { _ in }
    var onReminderSnooze5: (MiloReminder) -> Void = { _ in }
    var onReminderSnooze15: (MiloReminder) -> Void = { _ in }
    var onReminderReschedule: (MiloReminder) -> Void = { _ in }
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
            .contextMenu {
                Button("Add Reminder") {
                    onAddReminder()
                }

                Button("Chat Reminder") {
                    onChatReminder()
                }

                Divider()

                Button("Hide Milo") {
                    onHideMilo()
                }
            }

            if stateStore.shouldShowReminderBubble, let activeReminder = stateStore.activeReminder {
                MiloReminderBubbleView(
                    reminder: activeReminder,
                    onDone: { onReminderDone(activeReminder) },
                    onSnooze5: { onReminderSnooze5(activeReminder) },
                    onSnooze15: { onReminderSnooze15(activeReminder) },
                    onReschedule: { onReminderReschedule(activeReminder) }
                )
                    .offset(y: -MiloLayout.designHeight - 14)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
                    .zIndex(30)
            }

            if let bubbleText {
                MiloReactionBubbleView(text: bubbleText)
                    .offset(y: -MiloLayout.designHeight - 14)
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
        if stateStore.shouldShowReminderBubble {
            return nil
        }

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
