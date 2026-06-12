//
//  MiloEye.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

struct MiloEye: View {
    enum Side {
        case left
        case right
    }

    let side: Side
    let blinkPhase: BlinkPhase

    /// Normalised pupil offset in `[-1, 1]` along each axis.
    let pupilOffset: CGSize

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let visibleHeight = max(height * blinkPhase.eyeOpenness, height * 0.08)
            let pupilX = pupilOffset.width * width * MiloLayout.pupilRange
            let pupilY = pupilOffset.height * height * MiloLayout.pupilRange
            let pupilWidth = width * MiloLayout.pupilWidth / MiloLayout.eyeWidth
            let pupilHeight = height * MiloLayout.pupilHeight / MiloLayout.eyeHeight

            ZStack(alignment: .bottom) {
                Color.clear

                ZStack {
                    eyeImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)

                    pupilImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: pupilWidth, height: pupilHeight)
                        .offset(x: pupilX, y: pupilY)
                }
                .frame(width: width, height: height)
                .mask(alignment: .bottom) {
                    Rectangle()
                        .frame(width: width, height: visibleHeight)
                }
            }
        }
        .animation(.smooth(duration: blinkPhase.animationDuration), value: blinkPhase)
        .accessibilityElement(children: .ignore)
        .accessibilityHidden(true)
    }

    private var eyeImage: Image {
        switch side {
        case .left:
            MiloAssets.leftEye
        case .right:
            MiloAssets.rightEye
        }
    }

    private var pupilImage: Image {
        switch side {
        case .left:
            MiloAssets.leftPupil
        case .right:
            MiloAssets.rightPupil
        }
    }
}

private extension BlinkPhase {
    var eyeOpenness: CGFloat {
        switch self {
        case .open:
            1
        case .threeQuarter:
            0.72
        case .halfClosed:
            0.42
        case .mostlyClosed:
            0.18
        case .closed:
            0.04
        }
    }

    var animationDuration: TimeInterval {
        switch self {
        case .open:
            0.10
        case .threeQuarter:
            0.06
        case .halfClosed:
            0.055
        case .mostlyClosed:
            0.05
        case .closed:
            0.045
        }
    }
}
