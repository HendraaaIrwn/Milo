//
//  MiloCharacter.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

struct MiloCharacter: View {
    let mood: MiloMood
    var mouseLocation: NSPoint? = nil
    var characterFrame: NSRect = .zero

    @StateObject private var blinkEngine = MiloBlinkEngine()
    @State private var moodAnimationPhase = false
    @State private var commandLineBlinkPhase = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let width = MiloLayout.designWidth
        let height = MiloLayout.designHeight
        let animationFrame = currentAnimationFrame

        ZStack {
            if mood == .typing {
                MiloAssets.commandLine
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.13)
                    .position(x: width * 0.13, y: height * 0.3)
                    .scaleEffect(commandLineBlinkPhase ? 1.04 : 1.0, anchor: .center)
                    .opacity(commandLineBlinkPhase ? 0.95 : 0.28)
                    .accessibilityHidden(true)
                    .zIndex(20)
            } else {
                MiloAssets.commandLine
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.13)
                    .position(x: width * 0.13, y: height * 0.3)
                    .zIndex(20)
            }

            MiloAssets.body
                .resizable()
                .frame(width: width, height: height)
                .accessibilityHidden(true)

            MiloMouth()
                .frame(
                    width: width * MiloLayout.mouthWidth,
                    height: height * MiloLayout.mouthHeight
                )
                .scaleEffect(
                    x: animationFrame.mouthScaleX,
                    y: animationFrame.mouthScaleY,
                    anchor: .center
                )
                .position(
                    x: width * MiloLayout.mouthX,
                    y: height * MiloLayout.mouthY
                )

            MiloEyesView(
                mouseLocation: mouseLocation,
                characterFrame: characterFrame,
                blinkPhase: effectivePhase,
                bodyOffsetY: animationFrame.bodyOffsetY,
                fallbackPupilOffset: currentAnimationFrame.pupilOffset
            )
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(animationFrame.bodyRotation))
        .offset(y: height * animationFrame.bodyOffsetY)
        .frame(width: width, height: height)
        .fixedSize()
        .task(id: animationTaskID) {
            await startMoodAnimation(mood.animationConfiguration)
        }
        .task(id: commandLineBlinkTaskID) {
            await startCommandLineBlink()
        }
        .onAppear {
            blinkEngine.frequencyPerSecond = mood.blinkFrequencyPerSecond
            blinkEngine.start()
        }
        .onDisappear {
            blinkEngine.stop()
        }
        .onChange(of: mood) { _, newMood in
            blinkEngine.frequencyPerSecond = newMood.blinkFrequencyPerSecond
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Milo")
        .accessibilityInputLabels(["Milo", "Companion", "Assistant"])
    }

    private var effectivePhase: BlinkPhase {
        reduceMotion ? .open : blinkEngine.phase
    }

    private var currentAnimationFrame: MiloAnimationFrame {
        guard !reduceMotion else { return MiloAnimationFrame() }
        return moodAnimationPhase ? mood.animationConfiguration.activeFrame : mood.animationConfiguration.restingFrame
    }

    private var animationTaskID: String {
        "\(mood.animationConfiguration.id)-\(reduceMotion)"
    }

    private var commandLineBlinkTaskID: String {
        "\(mood)-\(reduceMotion)-commandLine"
    }

    @MainActor
    private func startMoodAnimation(_ configuration: MiloAnimationConfiguration) async {
        moodAnimationPhase = false

        guard !reduceMotion, let animation = configuration.animation else { return }

        await Task.yield()

        withAnimation(animation) {
            moodAnimationPhase = true
        }
    }

    @MainActor
    private func startCommandLineBlink() async {
        commandLineBlinkPhase = mood == .typing

        guard mood == .typing, !reduceMotion else { return }

        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: 0.12)) {
                commandLineBlinkPhase = true
            }

            guard await sleep(milliseconds: 420) else { return }

            withAnimation(.easeInOut(duration: 0.08)) {
                commandLineBlinkPhase = false
            }

            guard await sleep(milliseconds: 120) else { return }

            withAnimation(.easeInOut(duration: 0.1)) {
                commandLineBlinkPhase = true
            }

            guard await sleep(milliseconds: 760) else { return }
        }
    }

    private func sleep(milliseconds: UInt64) async -> Bool {
        do {
            try await Task.sleep(nanoseconds: milliseconds * 1_000_000)
            return true
        } catch {
            return false
        }
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Idle") {
    MiloCharacter(mood: .idle)
        .padding()
        .background(.background)
}
#endif

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Sleepy") {
    MiloCharacter(mood: .sleepy)
        .padding()
        .background(.background)
}
#endif

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Happy") {
    MiloCharacter(mood: .happy)
        .padding()
        .background(.background)
}
#endif

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Typing") {
    MiloCharacter(mood: .typing)
        .padding()
        .background(.background)
}
#endif

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Confused") {
    MiloCharacter(mood: .confused)
        .padding()
        .background(.background)
}
#endif

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Reminder") {
    MiloCharacter(mood: .reminder)
        .padding()
        .background(.background)
}
#endif

#if ENABLE_SWIFTUI_PREVIEWS
#Preview("Milo · Focus") {
    MiloCharacter(mood: .focus)
        .padding()
        .background(.background)
}
#endif
