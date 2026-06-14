//
//  MiloAnimationFrame.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import CoreGraphics

struct MiloAnimationFrame {
    let bodyScale: CGFloat
    let bodyRotation: Double
    let bodyOffsetY: CGFloat
    let mouthScaleX: CGFloat
    let mouthScaleY: CGFloat
    let pupilOffset: CGSize

    init(
        bodyScale: CGFloat = 1,
        bodyRotation: Double = 0,
        bodyOffsetY: CGFloat = 0,
        mouthScaleX: CGFloat = 1,
        mouthScaleY: CGFloat = 1,
        pupilOffset: CGSize = .zero
    ) {
        self.bodyScale = bodyScale
        self.bodyRotation = bodyRotation
        self.bodyOffsetY = bodyOffsetY
        self.mouthScaleX = mouthScaleX
        self.mouthScaleY = mouthScaleY
        self.pupilOffset = pupilOffset
    }
}
