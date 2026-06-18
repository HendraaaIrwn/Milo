//
//  MiloHomeView.swift
//  Milo
//
//  Created by Hendra Irawan on 11/06/26.
//

import SwiftUI

struct MiloHomeView: View {
    @State private var mood: MiloMood = .idle
    @State private var miloFrame: CGRect = .zero
    @State private var mouseLocation: CGPoint?

    var body: some View {
        ZStack {
            MiloHomeView.background

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "miloHome")
        .onPreferenceChange(MiloFramePreferenceKey.self) { frame in
            guard !frame.isEmpty else { return }
            miloFrame = frame
        }
        #if os(macOS)
        .overlay {
            TrackingMouseView(
                onMove: { mouseLocation = $0 },
                onExit: { mouseLocation = nil }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #endif
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 16)

            VStack(spacing: 10) {
                MiloChatBubble(mood: mood, onReply: advanceMood)
                    .id(mood)
                    .transition(.scale(scale: 0.96, anchor: .bottom).combined(with: .opacity))

                MiloCharacter(
                    mood: mood,
                    mouseLocation: mouseLocation,
                    characterFrame: miloFrame
                )
                    .frame(width: MiloLayout.designWidth, height: MiloLayout.designHeight)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: MiloFramePreferenceKey.self,
                                value: proxy.frame(in: .named("miloHome"))
                            )
                        }
                    }
                    .padding(.horizontal, 24)
            }

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
    }

    private func advanceMood() {
        let moods = MiloMood.allCases
        guard let currentIndex = moods.firstIndex(of: mood) else { return }
        let nextIndex = moods.index(after: currentIndex)

        withAnimation(.snappy(duration: 0.22)) {
            mood = nextIndex == moods.endIndex ? moods[0] : moods[nextIndex]
        }
    }

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

private struct MiloFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#if DEBUG
#Preview {
    MiloHomeView()
}
#endif
