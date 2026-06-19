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
                .miloFont(.headline)

            HStack {
                Label("+\(loc.linesAdded)", systemImage: "plus.circle.fill")
                    .foregroundStyle(Color.green)
                Label("-\(loc.linesDeleted)", systemImage: "minus.circle.fill")
                    .foregroundStyle(Color.red)
                Label("Net \(loc.netLines)", systemImage: "equal.circle.fill")
                    .foregroundStyle(Color.blue)
            }
            .miloFont(.roundedCallout, weight: .semibold)
        }
    }
}