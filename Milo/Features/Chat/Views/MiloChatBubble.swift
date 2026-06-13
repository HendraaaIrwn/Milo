//
//  MiloChatBubble.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

struct MiloChatBubble: View {
    let mood: MiloMood
    let onReply: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(mood.dialogue)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Reply", action: onReply)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.accentColor)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: 280, alignment: .leading)
            .background(.regularMaterial, in: .rect(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(.regularMaterial)
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(45))
                .offset(y: -10)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MiloChatBubble(mood: .idle, onReply: {})
        .padding()
}
