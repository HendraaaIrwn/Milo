//
//  MiloMood+AnimationConfiguration.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

extension MiloMood {
    var animationConfiguration: MiloAnimationConfiguration {
        switch self {
        case .idle:
            .idle
        case .typing:
            .typing
        case .happy:
            .happy
        case .confused:
            .confused
        case .sleepy:
            .sleepy
        case .reminder:
            .reminder
        case .focus:
            .focus
        }
    }
}
