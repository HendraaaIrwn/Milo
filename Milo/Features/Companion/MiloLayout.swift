//
//  MiloLayout.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import CoreGraphics

enum MiloLayout {
    static let designWidth: CGFloat = 320
    static let designHeight: CGFloat = 220
    static let aspectRatio = designWidth / designHeight

    static let pupilRange: CGFloat = 0.08

    static let leftEyeX: CGFloat = 0.278
    static let rightEyeX: CGFloat = 0.722
    static let eyeY: CGFloat = 0.555

    static let eyeWidth: CGFloat = 0.128
    static let eyeHeight: CGFloat = 0.309

    static let pupilWidth: CGFloat = 0.056
    static let pupilHeight: CGFloat = 0.155

    static let mouthX: CGFloat = 0.5
    static let mouthY: CGFloat = 0.748
    static let mouthWidth: CGFloat = 0.163
    static let mouthHeight: CGFloat = 0.045
}
