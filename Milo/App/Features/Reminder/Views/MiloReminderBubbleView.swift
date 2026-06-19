//
//  MiloReminderBubbleView.swift
//  Milo
//

import SwiftUI

struct MiloReminderBubbleView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var metrics = MiloScaledMetrics()
    
    let reminder: MiloReminder
    let onDone: () -> Void
    let onSnooze5: () -> Void
    let onSnooze15: () -> Void
    let onReschedule: () -> Void
    let onVisualFrameChange: (CGRect) -> Void
    
    init(
        reminder: MiloReminder,
        onDone: @escaping () -> Void,
        onSnooze5: @escaping () -> Void,
        onSnooze15: @escaping () -> Void,
        onReschedule: @escaping () -> Void,
        onVisualFrameChange: @escaping (CGRect) -> Void = { _ in }
    ) {
        self.reminder = reminder
        self.onDone = onDone
        self.onSnooze5 = onSnooze5
        self.onSnooze15 = onSnooze15
        self.onReschedule = onReschedule
        self.onVisualFrameChange = onVisualFrameChange
    }
    
    var body: some View {
        let bubbleWidth = maxBubbleWidth(for: dynamicTypeSize)
        
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                titleBar
                
                MiloTerminalTextView(
                    text: reminder.message,
                    typingSpeed: 0.022,
                    cursorStyle: .block,
                    keepCursorAfterTyping: false,
                    maxLines: nil
                )
                .foregroundStyle(.green.opacity(0.92))
                
                MiloAdaptiveActionRow(spacing: metrics.smallSpacing) {
                    Button { onDone() } label: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                    
                    Button { onSnooze5() } label: {
                        Label("+5", systemImage: "clock.fill")
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.bubbleSecondary))
                    
//                    Button { onSnooze15() } label: {
//                        Label("+15", systemImage: "clock.fill")
//                    }
//                    .buttonStyle(MiloAdaptiveButtonStyle(.bubbleSecondary))
                    
                    Button { onReschedule() } label: {
                        Label("Reschedule", systemImage: "calendar")
                    }
                    .buttonStyle(MiloAdaptiveButtonStyle(.bubbleSubtle))
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, metrics.bubblePaddingHorizontal)
            .padding(.vertical, metrics.bubblePaddingVertical)
            .frame(width: bubbleWidth, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(bubbleBackground)
            
            Triangle()
                .fill(Color.black.opacity(0.9))
                .frame(width: 14, height: 8)
                .offset(y: -1)
        }
        .miloReportVisualFrame(onChange: onVisualFrameChange)
        .miloBubbleDynamicTypeLimit()
    }
    
    private func maxBubbleWidth(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 500 : 368
    }
    
    private var titleBar: some View {
        HStack(spacing: metrics.smallSpacing) {
            trafficLight(.red)
            trafficLight(.yellow)
            trafficLight(.green)
            
            Text("milo.remind")
                .font(.caption2.monospaced().weight(.semibold))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer(minLength: 0)
        }
    }
    
    private func trafficLight(_ color: Color) -> some View {
        Circle()
            .fill(color.opacity(0.8))
            .frame(width: 7, height: 7)
    }
    
    private var bubbleBackground: some View {
        RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
            .fill(Color.black.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .stroke(Color.green.opacity(0.25), lineWidth: 1)
            )
    }
}
