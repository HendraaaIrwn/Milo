//
//  MiloReactionBubbleView.swift
//  Milo
//

import SwiftUI

struct MiloReactionBubbleView: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
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

                    Text("milo.term")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.45))

                    Spacer()
                }

                MiloTerminalTextView(
                    text: text,
                    typingSpeed: 0.026,
                    cursorStyle: .underline,
                    keepCursorAfterTyping: true,
                    fontSize: 13,
                    maxLines: 3
                )
                .foregroundStyle(.green.opacity(0.92))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: 260, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.green.opacity(0.28), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)

            Triangle()
                .fill(Color.black.opacity(0.88))
                .frame(width: 14, height: 8)
                .offset(y: -1)
        }
        .allowsHitTesting(false)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    MiloReactionBubbleView(
        text: "You've got 25 minutes of focus in the bag. Keep cooking."
    )
    .padding()
}
#endif
