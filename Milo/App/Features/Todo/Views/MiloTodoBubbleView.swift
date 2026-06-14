//
//  MiloTodoBubbleView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct MiloTodoBubbleView: View {
    let todo: MiloTodo
    let onDone: () -> Void
    let onOpenTodoList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("📌")
                Text("Todo Overdue")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }

            Text(todo.title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .lineLimit(3)

            HStack(spacing: 6) {
                Button("Done") { onDone() }
                Button("Open List") { onOpenTodoList() }
            }
            .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(10)
        .frame(maxWidth: 240, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.opacity(0.95))
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        )
    }
}
