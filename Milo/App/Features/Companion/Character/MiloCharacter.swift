//
//  MiloCharacter.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

struct MiloCharacter: View {
    let mood: MiloMood
    var mouseLocation: CGPoint? = nil
    var characterFrame: CGRect = .zero

    @StateObject private var blinkEngine = MiloBlinkEngine()
    @State private var moodAnimationPhase = false
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
                    .frame(width: width * 0.82)
                    .position(x: width * 0.5, y: height * 0.93)
                    .scaleEffect(moodAnimationPhase ? 1.04 : 1.0, anchor: .center)
                    .opacity(0.95)
                    .accessibilityHidden(true)
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

            MiloEye(side: .left, blinkPhase: effectivePhase, pupilOffset: effectivePupilOffset)
                .frame(
                    width: width * MiloLayout.eyeWidth,
                    height: height * MiloLayout.eyeHeight
                )
                .position(
                    x: width * MiloLayout.leftEyeX,
                    y: height * MiloLayout.eyeY
                )

            MiloEye(side: .right, blinkPhase: effectivePhase, pupilOffset: effectivePupilOffset)
                .frame(
                    width: width * MiloLayout.eyeWidth,
                    height: height * MiloLayout.eyeHeight
                )
                .position(
                    x: width * MiloLayout.rightEyeX,
                    y: height * MiloLayout.eyeY
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

    private var effectivePupilOffset: CGSize {
        guard let trackingPupilOffset else {
            return clampedPupilOffset(currentAnimationFrame.pupilOffset)
        }

        return clampedPupilOffset(trackingPupilOffset)
    }

    private var trackingPupilOffset: CGSize? {
        guard let mouseLocation, !characterFrame.isEmpty else { return nil }

        let visualCenter = CGPoint(
            x: characterFrame.midX,
            y: characterFrame.midY + characterFrame.height * currentAnimationFrame.bodyOffsetY
        )
        let x = (mouseLocation.x - visualCenter.x) / (characterFrame.width * 0.5)
        let y = (mouseLocation.y - visualCenter.y) / (characterFrame.height * 0.5)
        let distance = hypot(x, y)

        guard distance > 0 else { return .zero }

        let scale = min(distance, 1) / distance

        return CGSize(
            width: x * scale * 2,
            height: y * scale * 2
        )
    }

    private func clampedPupilOffset(_ offset: CGSize) -> CGSize {
        return CGSize(
            width: max(-2, min(2, offset.width)),
            height: max(-2, min(2, offset.height))
        )
    }

    private var animationTaskID: String {
        "\(mood.animationConfiguration.id)-\(reduceMotion)"
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
