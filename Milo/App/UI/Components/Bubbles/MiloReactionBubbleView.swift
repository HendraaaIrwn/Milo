//
//  MiloReactionBubbleView.swift
//  Milo
//

import SwiftUI

struct MiloReactionBubbleView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var metrics = MiloScaledMetrics()

    let text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        let usesLargeLayout = isLargeLayout(for: dynamicTypeSize)

        VStack(spacing: 0) {
            Group {
                if usesLargeLayout {
                    verticalLayout
                } else {
                    compactLayout
                }
            }
            .padding(.horizontal, metrics.bubblePaddingHorizontal)
            .padding(.vertical, metrics.bubblePaddingVertical)
            .frame(
                minWidth: 230,
                idealWidth: usesLargeLayout ? 360 : 320,
                maxWidth: usesLargeLayout ? 440 : 360,
                alignment: .leading
            )
            .fixedSize(horizontal: false, vertical: true)
            .background(bubbleBackground)

            Triangle()
                .fill(Color.black.opacity(0.88))
                .frame(width: 14, height: 8)
                .offset(y: -1)
        }
        .allowsHitTesting(false)
        .miloBubbleDynamicTypeLimit()
    }

    private func isLargeLayout(for dynamicTypeSize: DynamicTypeSize) -> Bool {
        dynamicTypeSize.isAccessibilitySize || dynamicTypeSize >= .xxLarge
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: metrics.smallSpacing) {
            titleBar
            terminalText
        }
    }

    private var verticalLayout: some View {
        VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
            titleBar
            terminalText
        }
    }

    private var titleBar: some View {
        HStack(spacing: metrics.smallSpacing) {
            trafficLight(.red)
            trafficLight(.yellow)
            trafficLight(.green)

            Text("milo.term")
                .miloFont(.monospacedCaption, weight: .semibold)
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
    }

    private var terminalText: some View {
        MiloTerminalTextView(
            text: text,
            typingSpeed: 0.026,
            cursorStyle: .underline,
            keepCursorAfterTyping: true,
            maxLines: nil
        )
        .foregroundStyle(.green.opacity(0.92))
    }

    private func trafficLight(_ color: Color) -> some View {
        Circle()
            .fill(color.opacity(0.8))
            .frame(width: 7, height: 7)
    }

    private var bubbleBackground: some View {
        RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
            .fill(Color.black.opacity(0.88))
            .overlay(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .stroke(Color.green.opacity(0.28), lineWidth: 1)
            )
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

#if DEBUG
#Preview("Bubble - Normal") {
    MiloReactionBubbleView(text: "Codex needs permission. Tiny approval bell.")
        .padding()
        .dynamicTypeSize(.medium)
}

#Preview("Bubble - Accessibility") {
    MiloReactionBubbleView(text: "Codex needs permission. Tiny approval bell.")
        .padding()
        .dynamicTypeSize(.accessibility2)
}
#endif