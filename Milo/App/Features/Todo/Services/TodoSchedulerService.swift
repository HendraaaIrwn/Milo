//
//  TodoSchedulerService.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import Foundation

@MainActor
final class TodoSchedulerService {
    private let todoService: TodoService
    private let miloStateStore: MiloStateStore

    private var timerTask: Task<Void, Never>?
    private var alreadyShownOverdueTodoIDs: Set<UUID> = []

    init(
        todoService: TodoService,
        miloStateStore: MiloStateStore
    ) {
        self.todoService = todoService
        self.miloStateStore = miloStateStore
    }

    func start() {
        stop()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                await MainActor.run { self?.checkOverdueTodos() }
                try? await Task.sleep(nanoseconds: 60_000_000_000)
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func checkOverdueTodos() {
        todoService.refreshOverdueStatus()
        todoService.save()

        guard !miloStateStore.shouldShowTodoBubble else { return }

        guard let overdue = todoService.overdueTodos().first else { return }
        guard !alreadyShownOverdueTodoIDs.contains(overdue.id) else { return }

        alreadyShownOverdueTodoIDs.insert(overdue.id)

        miloStateStore.showTodoOverdueBubble(overdue)
        MiloMumbleEngine.shared.speak("Todo overdue.")
    }

    func markDone(_ todo: MiloTodo) {
        todoService.markDone(id: todo.id)
        miloStateStore.hideTodoBubble()
        alreadyShownOverdueTodoIDs.remove(todo.id)
    }
}
