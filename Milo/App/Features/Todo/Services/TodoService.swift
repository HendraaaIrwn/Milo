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
        refreshOverdueStatus()
        sortTodos()
    }

    func save() {
        storage.save(todos, forKey: MiloStorageKeys.todos)
    }

    @discardableResult
    func addTodo(
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        priority: TodoPriority = .normal,
        createdSource: TodoCreatedSource = .chat
    ) -> MiloTodo {
        let todo = MiloTodo(
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority,
            createdSource: createdSource
        )

        todos.append(todo)
        refreshOverdueStatus()
        sortTodos()
        save()

        return todo
    }

    func updateTodo(_ todo: MiloTodo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }

        var updated = todo
        updated.updatedAt = Date()

        todos[index] = updated
        refreshOverdueStatus()
        sortTodos()
        save()
    }

    func markDone(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        todos[index].status = .done
        todos[index].updatedAt = Date()
        save()
    }

    func toggleDone(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        if todos[index].status == .done {
            todos[index].status = .active
        } else {
            todos[index].status = .done
        }

        todos[index].updatedAt = Date()
        refreshOverdueStatus()
        sortTodos()
        save()
    }

    func deleteTodo(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        todos[index].status = .deleted
        todos[index].updatedAt = Date()
        save()
    }

    func permanentlyRemoveDeleted() {
        todos.removeAll { $0.status == .deleted }
        save()
    }

    func attachReminder(todoID: UUID, reminderID: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == todoID }) else { return }

        todos[index].linkedReminderID = reminderID
        todos[index].updatedAt = Date()
        save()
    }

    func activeTodos() -> [MiloTodo] {
        todos.filter { $0.status == .active || $0.status == .overdue }
    }

    func activeTodoCount() -> Int {
        activeTodos().count
    }

    func overdueTodos(now: Date = Date()) -> [MiloTodo] {
        todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return todo.status != .done &&
                todo.status != .deleted &&
                dueDate <= now
        }
    }

    func refreshOverdueStatus(now: Date = Date()) {
        for index in todos.indices {
            guard todos[index].status != .done,
                  todos[index].status != .deleted,
                  let dueDate = todos[index].dueDate
            else { continue }

            if dueDate <= now {
                todos[index].status = .overdue
            } else if todos[index].status == .overdue {
                todos[index].status = .active
            }
        }
    }

    private func sortTodos() {
        todos.sort { lhs, rhs in
            if lhs.status == .done && rhs.status != .done { return false }
            if lhs.status != .done && rhs.status == .done { return true }

            let lhsDate = lhs.dueDate ?? .distantFuture
            let rhsDate = rhs.dueDate ?? .distantFuture
            return lhsDate < rhsDate
        }
    }
}
