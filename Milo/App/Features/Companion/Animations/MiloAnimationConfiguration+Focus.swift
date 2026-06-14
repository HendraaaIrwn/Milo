//
//  MiloAnimationConfiguration+Focus.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

extension MiloAnimationConfiguration {
    static var focus: MiloAnimationConfiguration {
        MiloAnimationConfiguration(
            id: "focus",
            restingFrame: MiloAnimationFrame(
                bodyScale: 1,
                pupilOffset: CGSize(width: 0, height: -0.08)
            ),
            activeFrame: MiloAnimationFrame(
                bodyScale: 1.006,
                bodyOffsetY: -0.004,
                mouthScaleX: 0.96,
                pupilOffset: CGSize(width: 0, height: -0.22)
            ),
            animation: .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
        )
    }
}
