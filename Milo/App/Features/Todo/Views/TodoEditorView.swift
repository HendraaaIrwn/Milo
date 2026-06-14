//
//  TodoEditorView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct TodoEditorView: View {
    @ObservedObject var todoService: TodoService
    @ObservedObject var reminderService: ReminderService

    let existingTodo: MiloTodo?
    let source: TodoCreatedSource
    let onSave: (MiloTodo) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var convertToReminder: Bool

    init(
        todoService: TodoService,
        reminderService: ReminderService,
        existingTodo: MiloTodo? = nil,
        source: TodoCreatedSource,
        onSave: @escaping (MiloTodo) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.todoService = todoService
        self.reminderService = reminderService
        self.existingTodo = existingTodo
        self.source = source
        self.onSave = onSave
        self.onCancel = onCancel

        _title = State(initialValue: existingTodo?.title ?? "")
        _notes = State(initialValue: existingTodo?.notes ?? "")
        _hasDueDate = State(initialValue: existingTodo?.dueDate != nil)
        _dueDate = State(initialValue: existingTodo?.dueDate ?? Date().addingTimeInterval(60 * 60))
        _convertToReminder = State(initialValue: existingTodo?.linkedReminderID != nil)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(existingTodo == nil ? "Add Todo" : "Edit Todo")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            TextField("Todo title", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(.roundedBorder)

            Toggle("Add due time", isOn: $hasDueDate)

            if hasDueDate {
                DatePicker(
                    "Due",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            Toggle("Convert to reminder", isOn: $convertToReminder)
                .disabled(!hasDueDate)

            HStack {
                Spacer()
                Button("Cancel") { onCancel() }
                Button("Save") { saveTodo() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isValid)
            }
        }
        .padding(18)
        .frame(width: 380, height: 300)
    }

    private func saveTodo() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDueDate = hasDueDate ? dueDate : nil

        let todo: MiloTodo

        if var existingTodo {
            existingTodo.title = cleanTitle
            existingTodo.notes = cleanNotes.isEmpty ? nil : cleanNotes
            existingTodo.dueDate = finalDueDate
            todoService.updateTodo(existingTodo)
            todo = existingTodo
        } else {
            todo = todoService.addTodo(
                title: cleanTitle,
                notes: cleanNotes.isEmpty ? nil : cleanNotes,
                dueDate: finalDueDate,
                createdSource: source
            )
        }

        if convertToReminder, let finalDueDate {
            let reminder = reminderService.addReminder(
                title: cleanTitle,
                message: cleanTitle,
                dueDate: finalDueDate,
                createdSource: .todo
            )

            todoService.attachReminder(todoID: todo.id, reminderID: reminder.id)
            ReminderNotificationService.shared.scheduleNotification(for: reminder)
        }

        onSave(todo)
    }
}
