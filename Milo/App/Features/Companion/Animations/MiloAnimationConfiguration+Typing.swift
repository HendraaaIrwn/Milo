//
//  MiloAnimationConfiguration+Typing.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

extension MiloAnimationConfiguration {
    static var typing: MiloAnimationConfiguration {
        MiloAnimationConfiguration(
            id: "typing",
            restingFrame: MiloAnimationFrame(
                bodyScale: 1.005,
                pupilOffset: CGSize(width: -0.22, height: 0.08)
            ),
            activeFrame: MiloAnimationFrame(
                bodyScale: 1.018,
                bodyOffsetY: -0.008,
                mouthScaleX: 0.9,
                mouthScaleY: 1.12,
                pupilOffset: CGSize(width: 0.28, height: 0.08)
            ),
            animation: .easeInOut(duration: 0.24).repeatForever(autoreverses: true)
        )
    }
}
