import SwiftUI

struct MiloPomodoroTimerBadgeView: View {
    @ObservedObject var pomodoroService: PomodoroService

    var body: some View {
        let session = pomodoroService.session

        ZStack {
            PomodoroProgressRingView(
                progress: pomodoroService.progress(),
                mode: session.mode
            )

            VStack(spacing: 2) {
                Text(pomodoroService.formattedRemainingTime())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.17, green: 0.11, blue: 0.05))

                Text(session.mode == .focus ? "Focus" : "Break")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.58))

                if session.runState == .paused {
                    Text("Paused")
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.orange)
                }
            }
        }
        .frame(width: 112, height: 112)
        .padding(20)
        .background(Color.clear)
        .accessibilityLabel("Pomodoro \(session.mode == .focus ? "Focus" : "Break") timer")
    }
}
