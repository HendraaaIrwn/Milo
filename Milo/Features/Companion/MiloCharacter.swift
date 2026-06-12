//
//  MiloCharacter.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

struct MiloCharacter: View {
    let mood: MiloMood
    var pupilOffset: CGSize = .zero

    @State private var blinkEngine = MiloBlinkEngine()
    @State private var happyAnimationPhase = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            let availableHeight = proxy.size.height
            let width = min(availableWidth, availableHeight * MiloLayout.aspectRatio)
            let height = width / MiloLayout.aspectRatio

            ZStack {
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
                        x: shouldPlayHappyAnimation && happyAnimationPhase ? 1.18 : 1,
                        y: shouldPlayHappyAnimation && happyAnimationPhase ? 1.08 : 1,
                        anchor: .center
                    )
                    .position(
                        x: width * MiloLayout.mouthX,
                        y: height * MiloLayout.mouthY
                    )

                MiloEye(side: .left, blinkPhase: effectivePhase, pupilOffset: pupilOffset)
                    .frame(
                        width: width * MiloLayout.eyeWidth,
                        height: height * MiloLayout.eyeHeight
                    )
                    .position(
                        x: width * MiloLayout.leftEyeX,
                        y: height * MiloLayout.eyeY
                    )

                MiloEye(side: .right, blinkPhase: effectivePhase, pupilOffset: pupilOffset)
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
            .scaleEffect(shouldPlayHappyAnimation && happyAnimationPhase ? 1.04 : 1)
            .rotationEffect(.degrees(shouldPlayHappyAnimation && happyAnimationPhase ? -2.5 : 1.8))
            .offset(y: shouldPlayHappyAnimation && happyAnimationPhase ? -height * 0.035 : 0)
            .position(x: availableWidth / 2, y: availableHeight / 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(MiloLayout.aspectRatio, contentMode: .fit)
        .task(id: shouldPlayHappyAnimation) {
            happyAnimationPhase = false

            guard shouldPlayHappyAnimation else { return }

            withAnimation(.easeInOut(duration: 0.42).repeatForever(autoreverses: true)) {
                happyAnimationPhase = true
            }
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

    private var shouldPlayHappyAnimation: Bool {
        mood == .happy && !reduceMotion
    }
}

#Preview("Milo · Idle") {
    MiloCharacter(mood: .idle)
        .padding()
        .background(.background)
}

#Preview("Milo · Sleepy") {
    MiloCharacter(mood: .sleepy)
        .padding()
        .background(.background)
}

#Preview("Milo · Happy") {
    MiloCharacter(mood: .happy)
        .padding()
        .background(.background)
}
