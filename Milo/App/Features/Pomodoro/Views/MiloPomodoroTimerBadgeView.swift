import SwiftUI

struct MiloPomodoroTimerBadgeView: View {
    @ObservedObject var pomodoroService: PomodoroService
    @ScaledMetric(relativeTo: .caption) private var labelSpacing: CGFloat = 4
    @ScaledMetric(relativeTo: .caption) private var horizontalPadding: CGFloat = 6

    init(pomodoroService: PomodoroService) {
        self.pomodoroService = pomodoroService
    }

    var body: some View {
        let session = pomodoroService.session

        ZStack {
            PomodoroProgressRingView(
                progress: pomodoroService.progress(),
                mode: session.mode
            )

            VStack(spacing: labelSpacing) {
                Text(pomodoroService.formattedRemainingTime())
                    .miloFont(.title3, weight: .bold)
                .fontDesign(.monospaced)
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                    .foregroundStyle(Color(red: 0.17, green: 0.11, blue: 0.05))

                Text(session.mode == .focus ? "Focus" : "Break")
                    .miloFont(.caption2, weight: .medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(Color.black.opacity(0.58))

                if session.runState == .paused {
                    Text("Paused")
                        .miloFont(.caption2, weight: .semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.orange)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(width: 112, height: 112)
        .padding(20)
        .background(Color.clear)
        .accessibilityLabel("Pomodoro \(session.mode == .focus ? "Focus" : "Break") timer")
        .miloSmallOverlayDynamicTypeLimit()
    }
}