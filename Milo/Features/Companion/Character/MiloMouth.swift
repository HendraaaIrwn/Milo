//
//  MiloMouth.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

/// Milo's mouth — a single decorative asset layered above the body.
struct MiloMouth: View {
    var body: some View {
        MiloAssets.mouth
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}
