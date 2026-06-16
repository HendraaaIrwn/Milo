import SwiftUI

struct PomodoroProgressRingView: View {
    let progress: Double
    let mode: PomodoroMode

    private var ringColor: Color {
        switch mode {
        case .focus:
            return Color(red: 0.98, green: 0.74, blue: 0.16)
        case .breakTime:
            return Color(red: 0.95, green: 0.49, blue: 0.16)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 1.0, green: 0.98, blue: 0.91).opacity(0.96))

            Circle()
                .stroke(Color.yellow.opacity(0.18), lineWidth: 10)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.25), value: progress)

            TickMarksView()
                .padding(8)
        }
    }
}

private struct TickMarksView: View {
    var body: some View {
        ZStack {
            ForEach(0..<60, id: \.self) { index in
                Rectangle()
                    .fill(index % 5 == 0 ? Color.black.opacity(0.24) : Color.black.opacity(0.10))
                    .frame(width: index % 5 == 0 ? 1.4 : 0.8, height: index % 5 == 0 ? 7 : 4)
                    .offset(y: -42)
                    .rotationEffect(.degrees(Double(index) * 6))
            }
        }
    }
}
