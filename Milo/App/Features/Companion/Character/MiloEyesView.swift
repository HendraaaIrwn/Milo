//
//  MiloEyesView.swift
//  Milo
//

import AppKit
import SwiftUI

struct MiloEyesView: View {
    let mouseLocation: NSPoint?
    let characterFrame: NSRect
    let blinkPhase: BlinkPhase
    let bodyOffsetY: CGFloat
    let fallbackPupilOffset: CGSize

    var body: some View {
        let width = MiloLayout.designWidth
        let height = MiloLayout.designHeight

        ZStack {
            MiloEye(
                side: .left,
                blinkPhase: blinkPhase,
                pupilOffset: effectiveOffset
            )
            .frame(
                width: width * MiloLayout.eyeWidth,
                height: height * MiloLayout.eyeHeight
            )
            .position(
                x: width * MiloLayout.leftEyeX,
                y: height * MiloLayout.eyeY
            )

            MiloEye(
                side: .right,
                blinkPhase: blinkPhase,
                pupilOffset: effectiveOffset
            )
            .frame(
                width: width * MiloLayout.eyeWidth,
                height: height * MiloLayout.eyeHeight
            )
            .position(
                x: width * MiloLayout.rightEyeX,
                y: height * MiloLayout.eyeY
            )
        }
    }

    private var effectiveOffset: CGSize {
        guard let mouseLocation, characterFrame != .zero else {
            return clamped(fallbackPupilOffset)
        }

        let center = NSPoint(
            x: characterFrame.midX,
            y: characterFrame.midY + characterFrame.height * bodyOffsetY
        )

        let dx = mouseLocation.x - center.x
        let dy = mouseLocation.y - center.y

        let distance = max(sqrt(dx * dx + dy * dy), 1)

        let normalizedX = dx / distance
        let normalizedY = dy / distance

        return clamped(CGSize(
            width: normalizedX * 2,
            height: -normalizedY * 2
        ))
    }

    private func clamped(_ offset: CGSize) -> CGSize {
        CGSize(
            width: max(-2, min(2, offset.width)),
            height: max(-2, min(2, offset.height))
        )
    }
}
