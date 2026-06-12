//
//  MiloHomeView.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

struct MiloHomeView: View {
    @State private var mood: MiloMood = .idle

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 16)

            MiloCharacter(mood: mood)
                .frame(maxWidth: 320, maxHeight: 320)
                .padding(.horizontal, 24)

            VStack(spacing: 8) {
                Text("Hi, I'm Milo")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Your friendly assistant")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            Spacer()

            MiloMoodPicker(selection: $mood)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MiloHomeView.background)
    }

    /// Background colour that adapts to the host platform. iOS uses the
    /// system grouped background; macOS uses a soft window tone.
    private static var background: Color {
        #if os(iOS)
        Color(.systemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(.gray).opacity(0.1)
        #endif
    }
}

/// Horizontal scroller that lets the caller pick a mood. Kept as a
/// separate view so `MiloHomeView.body` stays small.
private struct MiloMoodPicker: View {
    @Binding var selection: MiloMood

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(MiloMood.allCases) { mood in
                    Button(mood.rawValue.capitalized, action: { selection = mood })
                        .buttonStyle(.bordered)
                        .tint(selection == mood ? .accentColor : .secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    MiloHomeView()
}
