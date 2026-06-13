//
//  MiloAnimationConfiguration+Sleepy.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

extension MiloAnimationConfiguration {
    static var sleepy: MiloAnimationConfiguration {
        MiloAnimationConfiguration(
            id: "sleepy",
            restingFrame: MiloAnimationFrame(
                bodyScale: 0.995,
                bodyOffsetY: 0.012,
                mouthScaleX: 0.96,
                pupilOffset: CGSize(width: 0, height: 0.18)
            ),
            activeFrame: MiloAnimationFrame(
                bodyScale: 0.985,
                bodyRotation: -1.2,
                bodyOffsetY: 0.028,
                mouthScaleX: 0.9,
                pupilOffset: CGSize(width: 0, height: 0.3)
            ),
            animation: .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
        )
    }
}
