//
//  MiloReminderBubbleView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
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
                    Text("⏰")
                    Text("Reminder")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }

                Text(reminder.message)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

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
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .controlSize(.small)
            }
            .foregroundStyle(.black.opacity(0.9))
            .padding(10)
            .frame(width: 300, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.orange.opacity(0.8), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
            )

            Triangle()
                .fill(Color.yellow.opacity(0.96))
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
