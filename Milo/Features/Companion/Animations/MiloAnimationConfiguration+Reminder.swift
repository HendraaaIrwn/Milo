//
//  MiloAnimationConfiguration+Reminder.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

extension MiloAnimationConfiguration {
    static var reminder: MiloAnimationConfiguration {
        MiloAnimationConfiguration(
            id: "reminder",
            restingFrame: MiloAnimationFrame(bodyRotation: -1.8),
            activeFrame: MiloAnimationFrame(
                bodyScale: 1.025,
                bodyRotation: 2.2,
                bodyOffsetY: -0.018,
                mouthScaleX: 1.1,
                pupilOffset: CGSize(width: 0, height: -0.12)
            ),
            animation: .easeInOut(duration: 0.34).repeatForever(autoreverses: true)
        )
    }
}
