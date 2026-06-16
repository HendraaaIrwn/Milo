//
//  TodoListView.swift
//  Milo
//
//  Created by Hendra Irawan on 14/06/26.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoService: TodoService
    let onAddTodo: () -> Void
    let onEditTodo: (MiloTodo) -> Void
    let onConvertToReminder: (MiloTodo) -> Void

    @State private var filter: TodoListFilter = .active
    @State private var showClearConfirmation = false

    init(
        todoService: TodoService,
        onAddTodo: @escaping () -> Void = {},
        onEditTodo: @escaping (MiloTodo) -> Void,
        onConvertToReminder: @escaping (MiloTodo) -> Void
    ) {
        self.todoService = todoService
        self.onAddTodo = onAddTodo
        self.onEditTodo = onEditTodo
        self.onConvertToReminder = onConvertToReminder
    }

    private var visibleTodos: [MiloTodo] {
        todoService.todos.filter { $0.status != .deleted }
    }

    private var filteredTodos: [MiloTodo] {
        visibleTodos.filter { filter.includes($0) }
    }

    private var activeCount: Int {
        visibleTodos.filter { $0.status == .active }.count
    }

    private var overdueCount: Int {
        visibleTodos.filter { $0.status == .overdue }.count
    }

    private var doneCount: Int {
        visibleTodos.filter { $0.status == .done }.count
    }

    var body: some View {
        MiloPanelScaffoldView(
            title: "Todo List",
            subtitle: "Manage active, overdue, and completed tasks.",
            systemImage: "list.bullet.clipboard",
            primaryActionTitle: "Add Todo",
            primaryActionSystemImage: "plus",
            primaryAction: onAddTodo
        ) {
            MiloPanelCardView(
                title: "Todo Status",
                subtitle: "A quick snapshot of task health."
            ) {
                LazyVGrid(columns: metricColumns, spacing: 16) {
                    MiloMetricCardView(title: "Active", value: "\(activeCount)", systemImage: "circle")
                    MiloMetricCardView(title: "Overdue", value: "\(overdueCount)", systemImage: "exclamationmark.triangle.fill")
                    MiloMetricCardView(title: "Done", value: "\(doneCount)", systemImage: "checkmark.circle.fill")
                    MiloMetricCardView(title: "Total", value: "\(visibleTodos.count)", systemImage: "tray.full.fill")
                }
            }

            MiloPanelCardView(
                title: "Filters",
                subtitle: "Focus the list by todo state.",
                trailing: AnyView(
                    HStack(spacing: 8) {
                        MiloStatusPillView(title: "\(filteredTodos.count) shown", systemImage: "line.3.horizontal.decrease.circle", tone: .info)
                    }
                )
            ) {
                HStack {
                    Picker("Filter", selection: $filter) {
                        ForEach(TodoListFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Spacer()
                    
                    if doneCount > 0 {
                        Button("Clear Done") { showClearConfirmation = true }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.large)
                    }
                }
            }

            MiloPanelCardView(
                title: "Tasks",
                subtitle: "Readable rows with priority, due date, status, and linked reminder."
            ) {
                if filteredTodos.isEmpty {
                    MiloEmptyStateView(
                        systemImage: "checklist.unchecked",
                        title: emptyTitle,
                        message: "Try: add todo: fix login bug",
                        buttonTitle: "Add Todo",
                        buttonSystemImage: "plus.circle.fill",
                        action: onAddTodo
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTodos) { todo in
                            TodoStyledRowView(
                                todo: todo,
                                onDone: { todoService.toggleDone(id: todo.id) },
                                onEdit: { onEditTodo(todo) },
                                onDelete: { todoService.deleteTodo(id: todo.id) },
                                onConvertToReminder: { onConvertToReminder(todo) }
                            )
                        }
                    }
                }
            }
        } footer: {
            MiloPanelFooterView(
                message: "Todos are stored locally on this Mac.",
                statusTitle: "\(todoService.activeTodoCount()) Active",
                statusTone: todoService.activeTodoCount() > 0 ? .info : .neutral
            )
        }
        .onAppear {
            todoService.refreshOverdueStatus()
        }
        .confirmationDialog("Clear completed todos?", isPresented: $showClearConfirmation) {
            Button("Clear All Done (\(doneCount))", role: .destructive) {
                todoService.clearCompletedTodos()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove all \(doneCount) done todos. This cannot be undone.")
        }
    }

    private var metricColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    private var emptyTitle: String {
        filter == .all ? "No todos yet." : "No \(filter.title.lowercased()) todos."
    }
}

private enum TodoListFilter: String, CaseIterable, Identifiable {
    case active
    case overdue
    case done
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active:
            return "Active"
        case .overdue:
            return "Overdue"
        case .done:
            return "Done"
        case .all:
            return "All"
        }
    }

    func includes(_ todo: MiloTodo) -> Bool {
        switch self {
        case .active:
            return todo.status == .active
        case .overdue:
            return todo.status == .overdue
        case .done:
            return todo.status == .done
        case .all:
            return true
        }
    }
}

private struct TodoStyledRowView: View {
    let todo: MiloTodo
    let onDone: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onConvertToReminder: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onDone) {
                Image(systemName: todo.status == .done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(todo.status == .done ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .firstTextBaseline) {
                    Text(todo.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .strikethrough(todo.status == .done)
                        .foregroundStyle(todo.status == .done ? .secondary : .primary)
                        .lineLimit(1)

                    Spacer()

                    Menu {
                        Button("Edit", action: onEdit)
                        if todo.linkedReminderID == nil {
                            Button("Convert to Reminder", action: onConvertToReminder)
                                .disabled(todo.dueDate == nil)
                        }
                        Divider()
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .menuStyle(.borderlessButton)
                }

                if let notes = todo.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    MiloStatusPillView(title: statusLabel, systemImage: statusIcon, tone: statusTone)
                    MiloStatusPillView(title: priorityLabel, systemImage: "flag.fill", tone: priorityTone)

                    if let dueDate = todo.dueDate {
                        MiloStatusPillView(title: dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar.badge.clock", tone: todo.status == .overdue ? .danger : .info)
                    }

                    if todo.linkedReminderID != nil {
                        MiloStatusPillView(title: "Reminder", systemImage: "bell.fill", tone: .warning)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(rowBackground)
        )
    }

    private var rowBackground: Color {
        switch todo.status {
        case .overdue:
            return Color.orange.opacity(0.10)
        case .done:
            return Color(NSColor.windowBackgroundColor).opacity(0.55)
        case .active, .deleted:
            return Color(NSColor.windowBackgroundColor).opacity(0.72)
        }
    }

    private var statusLabel: String {
        switch todo.status {
        case .active:
            return "Active"
        case .done:
            return "Done"
        case .overdue:
            return "Overdue"
        case .deleted:
            return "Deleted"
        }
    }

    private var statusIcon: String {
        switch todo.status {
        case .active:
            return "circle.fill"
        case .done:
            return "checkmark.circle.fill"
        case .overdue:
            return "exclamationmark.triangle.fill"
        case .deleted:
            return "trash.fill"
        }
    }

    private var statusTone: MiloStatusPillView.Tone {
        switch todo.status {
        case .active:
            return .info
        case .done:
            return .success
        case .overdue:
            return .danger
        case .deleted:
            return .neutral
        }
    }

    private var priorityLabel: String {
        switch todo.priority {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .high:
            return "High"
        }
    }

    private var priorityTone: MiloStatusPillView.Tone {
        switch todo.priority {
        case .low:
            return .neutral
        case .normal:
            return .info
        case .high:
            return .warning
        }
    }
}
