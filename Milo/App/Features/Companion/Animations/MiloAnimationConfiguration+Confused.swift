//
//  MiloAnimationConfiguration+Confused.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

extension MiloAnimationConfiguration {
    static var confused: MiloAnimationConfiguration {
        MiloAnimationConfiguration(
            id: "confused",
            restingFrame: MiloAnimationFrame(
                bodyRotation: -3,
                pupilOffset: CGSize(width: -0.28, height: -0.03)
            ),
            activeFrame: MiloAnimationFrame(
                bodyRotation: 3,
                bodyOffsetY: -0.006,
                mouthScaleX: 0.92,
                pupilOffset: CGSize(width: 0.28, height: 0.08)
            ),
            animation: .easeInOut(duration: 0.62).repeatForever(autoreverses: true)
        )
    }
}
