//
//  TodoEditorView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct TodoEditorView: View {
    private var metrics = MiloScaledMetrics()

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
        MiloResponsivePanelContainer(
            minWidth: 560,
            idealWidth: 760,
            maxWidth: 980,
            minHeight: 520,
            idealHeight: 680,
            maxHeight: 900
        ) {
            VStack(alignment: .leading, spacing: metrics.largeSpacing) {
                header
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
            }
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: metrics.mediumSpacing) {
                headerIcon
                headerText
                Spacer(minLength: metrics.smallSpacing)
            }

            VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                headerIcon
                headerText
            }
        }
    }

    private var headerIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.smallCornerRadius, style: .continuous)
                .fill(Color.yellow.opacity(0.22))
            Image(systemName: "checklist")
                .font(.system(size: metrics.largeIconSize, weight: .semibold))
                .foregroundStyle(.orange)
        }
        .frame(width: metrics.largeIconSize + 22, height: metrics.largeIconSize + 22)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: metrics.tinySpacing) {
            Text(existingTodo == nil ? "Add Todo" : "Edit Todo")
                .miloFont(.title3, weight: .bold)
                .fixedSize(horizontal: false, vertical: true)
            Text("Capture a task and optionally turn it into a reminder.")
                .miloFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TodoEditorContentView: View {
    private var metrics = MiloScaledMetrics()

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

    init(
        todoService: TodoService,
        reminderService: ReminderService,
        existingTodo: MiloTodo?,
        source: TodoCreatedSource,
        onSave: @escaping (MiloTodo) -> Void,
        onCancel: @escaping () -> Void,
        title: Binding<String>,
        notes: Binding<String>,
        priority: Binding<TodoPriority>,
        hasDueDate: Binding<Bool>,
        showEmptyWarning: Binding<Bool>,
        dueDate: Binding<Date>,
        convertToReminder: Binding<Bool>
    ) {
        self.todoService = todoService
        self.reminderService = reminderService
        self.existingTodo = existingTodo
        self.source = source
        self.onSave = onSave
        self.onCancel = onCancel
        self._title = title
        self._notes = notes
        self._priority = priority
        self._hasDueDate = hasDueDate
        self._showEmptyWarning = showEmptyWarning
        self._dueDate = dueDate
        self._convertToReminder = convertToReminder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.largeSpacing) {
            SettingsCardView(
                title: "Task Form",
                subtitle: "Keep the title short and add notes only when useful.",
                systemImage: "checklist"
            ) {
                VStack(alignment: .leading, spacing: metrics.cardPadding) {
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

                    MiloAdaptiveActionRow {
                        Button { saveTodo() } label: {
                            Label("Save", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                        .keyboardShortcut(.defaultAction)
                        Button("Cancel") { onCancel() }
                            .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                    }
                    .padding(.top, metrics.largeSpacing)
                }
            }

            if showEmptyWarning {
                SettingsCardView(
                    title: "Title Required",
                    subtitle: "Please enter a todo title before saving."
                ) {
                    Button("OK") { showEmptyWarning = false }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                }
            }

            SettingsCardView(
                title: "Reminder Option",
                subtitle: "A todo can become a reminder when it has a due time.",
                systemImage: "bell.badge"
            ) {
                VStack(alignment: .leading, spacing: metrics.cardPadding) {
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

                    MiloAdaptiveActionRow {
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
