//
//  MiloFloatingPetView.swift
//  Milo
//
//  Created by Hendra Irawan on 13/06/26.
//

import Combine
import SwiftUI

final class MiloFloatingPetState: ObservableObject {
    @Published var mood: MiloMood = .idle
}

struct MiloFloatingPetView: View {
    @ObservedObject var state: MiloFloatingPetState

    var body: some View {
        MiloRootView(state: state)
    }
}

#Preview {
    MiloFloatingPetView(state: MiloFloatingPetState())
        .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
}
