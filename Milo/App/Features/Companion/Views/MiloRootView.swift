//
//  MiloRootView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import SwiftUI

struct MiloRootView: View {
    static let windowWidth: CGFloat = 340
    static let windowHeight: CGFloat = 410

    @ObservedObject var state: MiloFloatingPetState
    @ObservedObject var stateStore: MiloStateStore
    @ObservedObject var pomodoroService: PomodoroService
    @ObservedObject var codingMetricsCoordinator: CodingMetricsCoordinator
    var contextMenuController: MiloContextMenuController?

    var onAddReminder: () -> Void = {}
    var onChatCommand: () -> Void = {}
    var onOpenReminderHistory: () -> Void = {}
    var onOpenTodoList: () -> Void = {}
    var onTodoOverdueDone: (MiloTodo) -> Void = { _ in }
    var onAddTodo: () -> Void = {}
    var onStartPomodoro: (PomodoroPreset) -> Void = { _ in }
    var onPausePomodoro: () -> Void = {}
    var onResumePomodoro: () -> Void = {}
    var onResetPomodoro: () -> Void = {}
    var onOpenPomodoroSettings: () -> Void = {}
    var onOpenCodingMetrics: () -> Void = {}
    var onOpenWeeklyCodingSummary: () -> Void = {}
    var onOpenSettings: () -> Void = {}
    var onHideMilo: () -> Void = {}
    var onReminderDone: (MiloReminder) -> Void = { _ in }
    var onReminderSnooze5: (MiloReminder) -> Void = { _ in }
    var onReminderSnooze15: (MiloReminder) -> Void = { _ in }
    var onReminderReschedule: (MiloReminder) -> Void = { _ in }

    @AppStorage(MiloSettingsKeys.eyeFollowCursor) private var eyeFollowCursor = true
    @AppStorage(MiloStorageKeys.pomodoroShowTimerBadge) private var showPomodoroBadge = true
    @AppStorage(MiloStorageKeys.codingMetricsShowBadge) private var showCodingMetricsBadge = true
    @State private var mouseLocation: CGPoint?
    @State private var characterFrame: CGRect = MiloRootView.defaultCharacterFrame

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            VStack(spacing: 4) {
                bubbleSlot
                    .frame(height: 112, alignment: .bottom)
                    .zIndex(30)

                ZStack {
                    MiloCharacter(
                        mood: state.mood,
                        mouseLocation: eyeFollowCursor && !stateStore.isContextMenuOpen ? mouseLocation : nil,
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
                    .allowsHitTesting(false)

                    if let contextMenuController {
                        MiloRightClickMenuRepresentable(
                            contextMenuController: contextMenuController,
                            onLeftClick: showRandomReaction
                        )
                        .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
                    }
                }
                .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)

                if shouldShowPomodoroBadge {
                    MiloPomodoroTimerBadgeView(pomodoroService: pomodoroService)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(5)
                }

                if showCodingMetricsBadge {
                    CodingMetricsBadgeView(service: codingMetricsCoordinator.localMetricsService)
                        .offset(y: 8)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(5)
                }
            }
        }
        .frame(width: Self.windowWidth, height: Self.windowHeight)
        .coordinateSpace(name: "miloRoot")
        .background(Color.clear)
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: pomodoroService.session.runState)
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
                onMove: { point in
                    guard !stateStore.isContextMenuOpen else { return }
                    mouseLocation = point
                },
                onExit: {
                    guard !stateStore.isContextMenuOpen else { return }
                    mouseLocation = nil
                }
            )
            .frame(width: Self.windowWidth, height: Self.windowHeight)
        }
        #endif
        .overlay(alignment: .topTrailing) {
            if state.reactionText == nil && !stateStore.shouldShowReminderBubble && !stateStore.shouldShowTodoBubble {
                TodoCountBadge(stateStore: stateStore)
            }
        }
    }

    private static var defaultCharacterFrame: CGRect {
        CGRect(
            x: (windowWidth - MiloLayout.designWidth) * 0.5,
            y: 116,
            width: MiloLayout.designWidth,
            height: MiloLayout.designHeight
        )
    }

    @ViewBuilder
    private var bubbleSlot: some View {
        if stateStore.shouldShowReminderBubble, let activeReminder = stateStore.activeReminder {
            MiloReminderBubbleView(
                reminder: activeReminder,
                onDone: { onReminderDone(activeReminder) },
                onSnooze5: { onReminderSnooze5(activeReminder) },
                onSnooze15: { onReminderSnooze15(activeReminder) },
                onReschedule: { onReminderReschedule(activeReminder) }
            )
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity.combined(with: .move(edge: .top))
                )
            )
        } else if stateStore.shouldShowTodoBubble, let todo = stateStore.activeTodoBubble {
            MiloTodoBubbleView(
                todo: todo,
                onDone: { onTodoOverdueDone(todo) },
                onOpenTodoList: { onOpenTodoList() }
            )
            .transition(.opacity)
        } else if let bubbleText {
            MiloReactionBubbleView(text: bubbleText)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    )
                )
                .allowsHitTesting(false)
        } else {
            Color.clear
        }
    }

    private var bubbleText: String? {
        if stateStore.shouldShowReminderBubble || stateStore.shouldShowTodoBubble {
            return nil
        }

        if stateStore.shouldShowTypingBubble, let typingBubbleText = stateStore.typingBubbleText {
            return typingBubbleText
        }

        return state.reactionText
    }

    private var shouldShowPomodoroBadge: Bool {
        showPomodoroBadge && (
            pomodoroService.session.runState == .running ||
            pomodoroService.session.runState == .paused
        )
    }

    private func showRandomReaction() {
        let text = MiloReactionLineProvider.randomLine(excluding: state.reactionText)
        withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
            state.showBubble(text)
        }
    }
}

struct TodoCountBadge: View {
    @ObservedObject var stateStore: MiloStateStore

    var body: some View {
        if stateStore.activeTodoCount > 0 {
            Text("\(stateStore.activeTodoCount)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red)
                .clipShape(Capsule())
                .offset(x: -12, y: 8)
                .zIndex(20)
        }
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
    MiloRootView(
        state: MiloFloatingPetState(),
        stateStore: MiloStateStore(),
        pomodoroService: PomodoroService(),
        codingMetricsCoordinator: CodingMetricsCoordinator(
            localMetricsService: CodingMetricsService(storage: .shared),
            weeklyMetricsService: WeeklyCodingMetricsService(storage: .shared),
            wakaTimeClient: WakaTimeClient()
        )
    )
}
#endif
