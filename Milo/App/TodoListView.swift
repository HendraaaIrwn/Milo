//
//  TodoListView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoService: TodoService
    @State private var newTodoTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MILO Todos")
                .font(.headline)

            HStack {
                TextField("New todo", text: $newTodoTitle)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    let title = newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }

                    todoService.addTodo(title: title)
                    newTodoTitle = ""
                }
                .keyboardShortcut(.defaultAction)
            }

            List {
                ForEach(todoService.todos) { todo in
                    HStack {
                        Button(todo.isDone ? "✓" : "○") {
                            todoService.toggleDone(id: todo.id)
                        }
                        .buttonStyle(.plain)

                        Text(todo.title)
                            .strikethrough(todo.isDone)
                            .foregroundStyle(todo.isDone ? .secondary : .primary)

                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        todoService.deleteTodo(id: todoService.todos[index].id)
                    }
                }
            }
        }
        .padding()
        .frame(width: 360, height: 420)
    }
}

#if ENABLE_SWIFTUI_PREVIEWS
#Preview {
    TodoListView(todoService: TodoService())
}
#endif
