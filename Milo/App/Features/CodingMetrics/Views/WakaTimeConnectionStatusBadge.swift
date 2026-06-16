//
//  WakaTimeConnectionStatusBadge.swift
//  Milo
//

import SwiftUI

struct WakaTimeConnectionStatusBadge: View {
    let status: WakaTimeConnectionStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(status.title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.14))
        )
        .foregroundStyle(color)
    }

    var color: Color {
        switch status {
        case .connected: return .green
        case .checking: return .yellow
        case .invalidAPIKey, .forbidden, .badRequest, .serverError, .unknownError: return .red
        case .networkError, .rateLimited: return .orange
        case .notConnected: return .secondary
        }
    }
}
