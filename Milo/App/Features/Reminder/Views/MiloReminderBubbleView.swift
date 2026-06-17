//
//  MiloReminderBubbleView.swift
//  Milo
//

import SwiftUI

struct MiloReminderBubbleView: View {
    let reminder: MiloReminder
    let onDone: () -> Void
    let onSnooze5: () -> Void
    let onSnooze15: () -> Void
    let onReschedule: () -> Void

    var body: some View {
        VStack(spacing: 0) {
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

                    Text("milo.remind")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.45))

                    Spacer()
                }

                MiloTerminalTextView(
                    text: reminder.message,
                    typingSpeed: 0.022,
                    cursorStyle: .block,
                    keepCursorAfterTyping: false,
                    fontSize: 13,
                    maxLines: 3
                )
                .foregroundStyle(.green.opacity(0.92))

                HStack(spacing: 6) {
                    Button("Done", action: onDone)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    Button("+5", action: onSnooze5)
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                    Button("+15", action: onSnooze15)
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                    Button("Reschedule", action: onReschedule)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                }
                .font(.system(size: 10, weight: .semibold))
                .controlSize(.small)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: 320, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.green.opacity(0.25), lineWidth: 1)
                    )
            )

            Triangle()
                .fill(Color.black.opacity(0.9))
                .frame(width: 14, height: 8)
                .offset(y: -1)
        }
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloReminderBubbleView(
        reminder: MiloReminder(
            title: "Take a break",
            message: "Take a break",
            dueDate: Date(),
            createdSource: .rightClick
        ),
        onDone: {},
        onSnooze5: {},
        onSnooze15: {},
        onReschedule: {}
    )
}
#endif
