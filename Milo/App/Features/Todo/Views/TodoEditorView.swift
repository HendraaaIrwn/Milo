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
    @State private var priority: TodoPriority
    @State private var hasDueDate: Bool
    @State private var showEmptyWarning = false
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
        _priority = State(initialValue: existingTodo?.priority ?? .normal)
        _hasDueDate = State(initialValue: existingTodo?.dueDate != nil)
        _dueDate = State(initialValue: existingTodo?.dueDate ?? Date().addingTimeInterval(60 * 60))
        _convertToReminder = State(initialValue: existingTodo?.linkedReminderID != nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                TodoEditorContentView(
                    todoService: todoService,
                    reminderService: reminderService,
                    existingTodo: existingTodo,
                    source: source,
                    onSave: onSave,
                    onCancel: onCancel,
                    title: $title,
                    notes: $notes,
                    priority: $priority,
                    hasDueDate: $hasDueDate,
                    showEmptyWarning: $showEmptyWarning,
                    dueDate: $dueDate,
                    convertToReminder: $convertToReminder
                )
                .padding(22)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 520, minHeight: 560)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.22))
                Image(systemName: "checklist")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(existingTodo == nil ? "Add Todo" : "Edit Todo")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("Capture a task and optionally turn it into a reminder.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
}

struct TodoEditorContentView: View {
    @ObservedObject var todoService: TodoService
    @ObservedObject var reminderService: ReminderService

    let existingTodo: MiloTodo?
    let source: TodoCreatedSource
    let onSave: (MiloTodo) -> Void
    let onCancel: () -> Void

    @Binding var title: String
    @Binding var notes: String
    @Binding var priority: TodoPriority
    @Binding var hasDueDate: Bool
    @Binding var showEmptyWarning: Bool
    @Binding var dueDate: Date
    @Binding var convertToReminder: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsCardView(
                title: "Task Form",
                subtitle: "Keep the title short and add notes only when useful.",
                systemImage: "checklist"
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    TextField("Todo title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Notes (optional)", text: $notes)
                        .textFieldStyle(.roundedBorder)

                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(TodoPriority.low)
                        Text("Normal").tag(TodoPriority.normal)
                        Text("High").tag(TodoPriority.high)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Spacer()
                        Button("Cancel") { onCancel() }
                        Button { saveTodo() } label: {
                            Label("Save", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }

            if showEmptyWarning {
                SettingsCardView(
                    title: "Title Required",
                    subtitle: "Please enter a todo title before saving."
                ) {
                    Button("OK") { showEmptyWarning = false }
                }
            }

            SettingsCardView(
                title: "Reminder Option",
                subtitle: "A todo can become a reminder when it has a due time.",
                systemImage: "bell.badge"
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    Toggle("Add due time", isOn: $hasDueDate)
                        .onChange(of: hasDueDate) { _, _ in
                            if !hasDueDate { convertToReminder = false }
                        }

                    if hasDueDate {
                        DatePicker(
                            "Due",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }

                    Toggle("Convert to reminder", isOn: $convertToReminder)
                        .disabled(!hasDueDate)

                    HStack(spacing: 8) {
                        MiloStatusPillView(title: priorityLabel, systemImage: "flag.fill", tone: priorityTone)
                        MiloStatusPillView(title: hasDueDate ? dueDate.formatted(date: .abbreviated, time: .shortened) : "No due time", systemImage: "calendar.badge.clock", tone: hasDueDate ? .info : .neutral)
                        MiloStatusPillView(title: convertToReminder ? "Reminder" : "Todo Only", systemImage: convertToReminder ? "bell.fill" : "checklist", tone: convertToReminder ? .warning : .neutral)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        !cleanTitle.isEmpty
    }

    private var priorityLabel: String {
        switch priority {
        case .low: return "Low Priority"
        case .normal: return "Normal Priority"
        case .high: return "High Priority"
        }
    }

    private var priorityTone: MiloStatusPillView.Tone {
        switch priority {
        case .low: return .neutral
        case .normal: return .info
        case .high: return .warning
        }
    }

    private func saveTodo() {
        guard isValid else {
            showEmptyWarning = true
            return
        }

        let finalDueDate = hasDueDate ? dueDate : nil
        let todo: MiloTodo

        if var existingTodo {
            existingTodo.title = cleanTitle
            existingTodo.notes = cleanNotes.isEmpty ? nil : cleanNotes
            existingTodo.priority = priority
            existingTodo.dueDate = finalDueDate
            todoService.updateTodo(existingTodo)
            todo = existingTodo
        } else {
            todo = todoService.addTodo(
                title: cleanTitle,
                notes: cleanNotes.isEmpty ? nil : cleanNotes,
                dueDate: finalDueDate,
                priority: priority,
                createdSource: source
            )
        }

        if convertToReminder, let finalDueDate, todo.linkedReminderID == nil {
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
