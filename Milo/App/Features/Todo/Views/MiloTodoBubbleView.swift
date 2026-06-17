//
//  MiloTodoBubbleView.swift
//  Milo
//

import SwiftUI

struct MiloTodoBubbleView: View {
    let todo: MiloTodo
    let onDone: () -> Void
    let onOpenTodoList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(.red.opacity(0.8))
                    .frame(width: 7, height: 7)
                Circle()
                    .fill(.yellow.opacity(0.8))
                    .frame(width: 7, height: 7)
                Circle()
                    .fill(.green.opacity(0.8))
                    .frame(width: 7, height: 7)

                Text("milo.todo")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))

                Spacer()
            }

            MiloTerminalTextView(
                text: "Todo overdue: \(todo.title)",
                typingSpeed: 0.022,
                cursorStyle: .block,
                keepCursorAfterTyping: false,
                fontSize: 13,
                maxLines: 3
            )
            .foregroundStyle(.green.opacity(0.92))

            HStack(spacing: 6) {
                Button("Done") { onDone() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.small)
                Button("Open List") { onOpenTodoList() }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                    .controlSize(.small)
            }
            .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 280, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.green.opacity(0.25), lineWidth: 1)
                )
        )
    }
}
