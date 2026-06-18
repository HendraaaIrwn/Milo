//
//  MiloAgentStatusBadgeView.swift
//  Milo
//

import SwiftUI

struct MiloAgentStatusBadgeView: View {
    let event: MiloAgentEvent

    @State private var pulse = false

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: event.agentType.symbolName)
                .font(.system(size: 11, weight: .semibold))

            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
                .opacity(isActive ? (pulse ? 1 : 0.3) : 0.8)

            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .lineLimit(1)
        }
        .foregroundStyle(textColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 4)
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var isActive: Bool {
        event.state == .running || event.state == .thinking
    }

    private var label: String {
        if event.agentType == .xcodeBuild {
            switch event.state {
            case .running:             return "Xcode building"
            case .done:                return "Build finished"
            case .failed:              return "Build failed"
            case .needsReview:         return "Review build"
            case .waitingForUserInput: return "Xcode waiting"
            case .thinking:            return "Xcode preparing"
            case .idle:                return "Idle"
            }
        }
        switch event.state {
        case .idle:              return "Idle"
        case .thinking:          return "Thinking"
        case .running:           return "\(event.agentType.displayName) running"
        case .waitingForUserInput: return "Waiting"
        case .done:              return "Done"
        case .failed:            return "Failed"
        case .needsReview:       return "Review"
        }
    }

    private var dotColor: Color {
        switch event.state {
        case .running, .thinking:           return .green
        case .waitingForUserInput:          return .yellow
        case .done, .needsReview:           return .green
        case .failed:                       return .red
        case .idle:                         return .gray
        }
    }

    private var textColor: Color {
        switch event.state {
        case .failed:  return .red.opacity(0.95)
        case .done, .needsReview, .running, .thinking: return .green.opacity(0.95)
        default:       return .green.opacity(0.95)
        }
    }

    private var borderColor: Color {
        switch event.state {
        case .failed:  return .red.opacity(0.35)
        default:       return .green.opacity(0.24)
        }
    }
}
