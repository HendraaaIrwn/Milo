//
//  MiloAnimationConfiguration.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

import SwiftUI

struct MiloAnimationConfiguration {
    let id: String
    let restingFrame: MiloAnimationFrame
    let activeFrame: MiloAnimationFrame
    let animation: Animation?

    init(
        id: String,
        restingFrame: MiloAnimationFrame = MiloAnimationFrame(),
        activeFrame: MiloAnimationFrame = MiloAnimationFrame(),
        animation: Animation? = nil
    ) {
        self.id = id
        self.restingFrame = restingFrame
        self.activeFrame = activeFrame
        self.animation = animation
    }
}
