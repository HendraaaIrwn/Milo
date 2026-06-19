//
//  MiloTodoBubbleView.swift
//  Milo
//

import SwiftUI

struct MiloTodoBubbleView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var metrics = MiloScaledMetrics()

    let todo: MiloTodo
    let onDone: () -> Void
    let onOpenTodoList: () -> Void
    let onVisualFrameChange: (CGRect) -> Void

    init(
        todo: MiloTodo,
        onDone: @escaping () -> Void,
        onOpenTodoList: @escaping () -> Void,
        onVisualFrameChange: @escaping (CGRect) -> Void = { _ in }
    ) {
        self.todo = todo
        self.onDone = onDone
        self.onOpenTodoList = onOpenTodoList
        self.onVisualFrameChange = onVisualFrameChange
    }

    var body: some View {
        let bubbleWidth = maxBubbleWidth(for: dynamicTypeSize)

        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            titleBar

            MiloTerminalTextView(
                text: "Todo overdue: \(todo.title)",
                typingSpeed: 0.022,
                cursorStyle: .block,
                keepCursorAfterTyping: false,
                maxLines: nil
            )
            .foregroundStyle(.green.opacity(0.92))

            MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                Button { onDone() } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.primary))

                Button { onOpenTodoList() } label: {
                    Label("Open List", systemImage: "list.bullet")
                }
                .buttonStyle(MiloAdaptiveButtonStyle(.bubbleSecondary))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, metrics.bubblePaddingHorizontal)
        .padding(.vertical, metrics.bubblePaddingVertical)
        .frame(width: bubbleWidth, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(bubbleBackground)
        .miloReportVisualFrame(onChange: onVisualFrameChange)
        .miloBubbleDynamicTypeLimit()
    }

    private func maxBubbleWidth(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 420 : 340
    }

    private var titleBar: some View {
        HStack(spacing: metrics.smallSpacing) {
            trafficLight(.red)
            trafficLight(.yellow)
            trafficLight(.green)

            Text("milo.todo")
                .miloFont(.monospacedCaption, weight: .semibold)
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
    }

    private func trafficLight(_ color: Color) -> some View {
        Circle()
            .fill(color.opacity(0.8))
            .frame(width: 7, height: 7)
    }

    private var bubbleBackground: some View {
        RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
            .fill(Color.black.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .stroke(Color.green.opacity(0.25), lineWidth: 1)
            )
    }
}
