//
//  MiloAnimationConfiguration+Happy.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

extension MiloAnimationConfiguration {
    static var happy: MiloAnimationConfiguration {
        MiloAnimationConfiguration(
            id: "happy",
            restingFrame: MiloAnimationFrame(bodyRotation: 1.8),
            activeFrame: MiloAnimationFrame(
                bodyScale: 1.04,
                bodyRotation: -2.5,
                bodyOffsetY: -0.035,
                mouthScaleX: 1.18,
                mouthScaleY: 1.08,
                pupilOffset: CGSize(width: 0, height: -0.18)
            ),
            animation: .easeInOut(duration: 0.42).repeatForever(autoreverses: true)
        )
    }
}
