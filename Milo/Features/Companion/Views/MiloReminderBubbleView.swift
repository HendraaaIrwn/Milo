//
//  MiloReminderBubbleView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct MiloReminderBubbleView: View {
    let message: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("⏰")
                    Text("Reminder")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }

                Text(message)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(.black.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: 220, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.orange.opacity(0.75), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
            )

            Triangle()
                .fill(Color.yellow.opacity(0.95))
                .frame(width: 14, height: 8)
                .offset(y: -1)
        }
        .allowsHitTesting(false)
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloReminderBubbleView(message: "Take a break")
}
#endif
