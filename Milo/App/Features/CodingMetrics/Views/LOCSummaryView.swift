//
//  LOCSummaryView.swift
//  Milo
//

import SwiftUI

struct LOCSummaryView: View {
    let loc: LOCSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lines of Code")
                .font(.headline)

            HStack {
                Label("+\(loc.linesAdded)", systemImage: "plus.circle.fill")
                    .foregroundStyle(Color.green)
                Label("-\(loc.linesDeleted)", systemImage: "minus.circle.fill")
                    .foregroundStyle(Color.red)
                Label("Net \(loc.netLines)", systemImage: "equal.circle.fill")
                    .foregroundStyle(Color.blue)
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
    }
}
