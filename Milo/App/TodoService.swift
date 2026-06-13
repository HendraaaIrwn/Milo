//
//  TodoService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Combine
import Foundation

@MainActor
final class TodoService: ObservableObject {
    @Published private(set) var todos: [MiloTodo] = []

    private let storage: MiloLocalStorageService

    convenience init() {
        self.init(storage: .shared)
    }

    init(storage: MiloLocalStorageService) {
        self.storage = storage
        load()
    }

    func load() {
        todos = storage.load(
            [MiloTodo].self,
            forKey: MiloStorageKeys.todos,
            defaultValue: []
        )
        sortTodos()
    }

    func save() {
        storage.save(todos, forKey: MiloStorageKeys.todos)
    }

    func addTodo(
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        priority: TodoPriority = .normal
    ) {
        let todo = MiloTodo(
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        )

        todos.append(todo)
        sortTodos()
        save()
    }

    func updateTodo(_ todo: MiloTodo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }

        var updated = todo
        updated.updatedAt = Date()
        todos[index] = updated
        sortTodos()
        save()
    }

    func markDone(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        todos[index].isDone = true
        todos[index].updatedAt = Date()
        save()
    }

    func toggleDone(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        todos[index].isDone.toggle()
        todos[index].updatedAt = Date()
        sortTodos()
        save()
    }

    func attachReminder(todoID: UUID, reminderID: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == todoID }) else { return }

        todos[index].linkedReminderID = reminderID
        todos[index].updatedAt = Date()
        save()
    }

    func deleteTodo(id: UUID) {
        todos.removeAll { $0.id == id }
        save()
    }

    func deleteCompleted() {
        todos.removeAll { $0.isDone }
        save()
    }

    private func sortTodos() {
        todos.sort { lhs, rhs in
            switch (lhs.isDone, rhs.isDone) {
            case (false, true):
                return true
            case (true, false):
                return false
            default:
                return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
            }
        }
    }
}
