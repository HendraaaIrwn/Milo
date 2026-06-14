//
//  TodoListView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoService: TodoService
    let onEditTodo: (MiloTodo) -> Void
    let onConvertToReminder: (MiloTodo) -> Void

    private var visibleTodos: [MiloTodo] {
        todoService.todos.filter { $0.status != .deleted }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MILO Todos")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Spacer()

                Text("\(todoService.activeTodoCount()) active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.14))
                    .clipShape(Capsule())
            }

            if visibleTodos.isEmpty {
                VStack(spacing: 8) {
                    Text("No todos yet.")
                        .font(.headline)
                    Text("Try: add todo: fix login bug")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(visibleTodos) { todo in
                        TodoRowView(
                            todo: todo,
                            onDone: { todoService.markDone(id: todo.id) },
                            onEdit: { onEditTodo(todo) },
                            onDelete: { todoService.deleteTodo(id: todo.id) },
                            onConvertToReminder: { onConvertToReminder(todo) }
                        )
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 480, height: 520)
    }
}
