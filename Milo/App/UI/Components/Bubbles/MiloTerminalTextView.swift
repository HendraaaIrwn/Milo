//
//  MiloTerminalTextView.swift
//  Milo
//

import SwiftUI

struct MiloTerminalTextView: View {
    let text: String
    var typingSpeed: TimeInterval = 0.026
    var cursorStyle: MiloTerminalCursorStyle = .underline
    var keepCursorAfterTyping: Bool = true
    var fontSize: CGFloat = 13
    var maxLines: Int = 3

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var displayedText: String = ""
    @State private var isCursorVisible: Bool = true
    @State private var typingTask: Task<Void, Never>?
    @State private var cursorTask: Task<Void, Never>?

    var body: some View {
        Text(renderedText)
            .font(.system(size: fontSize, weight: .medium, design: .monospaced))
            .lineLimit(maxLines)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear { startAnimation() }
            .onChange(of: text) { _, _ in startAnimation() }
            .onDisappear { cancelTasks() }
    }

    private var renderedText: String {
        let isTyping = displayedText.count < text.count
        let showCursor = isCursorVisible && (keepCursorAfterTyping || isTyping)
        return displayedText + (showCursor ? cursorStyle.symbol : " ")
    }

    private func startAnimation() {
        cancelTasks()

        if reduceMotion {
            displayedText = text
            startCursorBlink()
            return
        }

        displayedText = ""
        isCursorVisible = true
        startCursorBlink()
        startTyping()
    }

    private func startTyping() {
        let fullText = text
        typingTask = Task {
            var current = ""
            for character in fullText {
                if Task.isCancelled { return }
                current.append(character)
                await MainActor.run { displayedText = current }
                try? await Task.sleep(nanoseconds: UInt64(typingSpeed * 1_000_000_000))
            }
            await MainActor.run { displayedText = fullText }
        }
    }

    private func startCursorBlink() {
        cursorTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 450_000_000)
                await MainActor.run { isCursorVisible.toggle() }
            }
        }
    }

    private func cancelTasks() {
        typingTask?.cancel()
        typingTask = nil
        cursorTask?.cancel()
        cursorTask = nil
    }
}
