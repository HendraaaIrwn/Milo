//
//  ChatCommandWindowView.swift
//  Milo
//
//  PRIVACY: MILO does not store full chat transcripts.
//  Only the created reminder/todo metadata is saved locally.
//

import SwiftUI

struct ChatCommandWindowView: View {
    private var metrics = MiloScaledMetrics()

    let reminderService: ReminderService
    let todoService: TodoService
    let reminderSchedulerService: ReminderSchedulerService
    let todoSchedulerService: TodoSchedulerService
    let onShowBubble: (String) -> Void
    let onClose: () -> Void

    init(
        reminderService: ReminderService,
        todoService: TodoService,
        reminderSchedulerService: ReminderSchedulerService,
        todoSchedulerService: TodoSchedulerService,
        onShowBubble: @escaping (String) -> Void,
        onClose: @escaping () -> Void = {}
    ) {
        self.reminderService = reminderService
        self.todoService = todoService
        self.reminderSchedulerService = reminderSchedulerService
        self.todoSchedulerService = todoSchedulerService
        self.onShowBubble = onShowBubble
        self.onClose = onClose
    }

    @State private var commandText: String = ""
    @State private var helperText: String = "Try: remind me in 30 min to take a break"

    private let examples = [
        "remind me in 30 min to take a break",
        "ingatkan aku jam 3 untuk push commit",
        "add todo: fix login bug",
        "buat todo: update README besok jam 10"
    ]

    var body: some View {
        MiloPanelScaffoldView(
            title: "Chat Reminder & Todo",
            subtitle: "Type a natural language command for reminders or todos.",
            systemImage: "bubble.left.and.bubble.right.fill"
        ) {
            MiloPanelCardView(
                title: "Command",
                subtitle: "MILO turns simple commands into reminder or todo metadata."
            ) {
                VStack(alignment: .leading, spacing: metrics.mediumSpacing) {
                    TextField("Try: remind me in 30 min to take a break", text: $commandText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { submit() }

                    MiloAdaptiveActionRow(spacing: metrics.mediumSpacing) {
                        Button {
                            submit()
                        } label: {
                            Label("Submit", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.primary))
                        .keyboardShortcut(.defaultAction)
                        .disabled(commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        Button("Clear") {
                            commandText = ""
                            helperText = "Try: remind me in 30 min to take a break"
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.secondary))
                        
                        Spacer ()

                        Button("Close") {
                            onClose()
                        }
                        .buttonStyle(MiloAdaptiveButtonStyle(.subtle))
                    }
                    .padding(.top, metrics.largeSpacing)
                }
            }

            MiloPanelCardView(
                title: "Examples",
                subtitle: "English and Indonesian commands work best when simple."
            ) {
                LazyVStack(alignment: .leading, spacing: metrics.smallSpacing) {
                    ForEach(examples, id: \.self) { example in
                        HStack(alignment: .top, spacing: metrics.smallSpacing) {
                            Image(systemName: "quote.bubble.fill")
                                .foregroundStyle(.orange)
                                .miloFont(.caption)
                            
                            Text(example)
                                .miloFont(.caption, weight: .medium)
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            MiloPanelCardView(
                title: "Result",
                subtitle: "No full chat transcript is saved."
            ) {
                MiloStatusPillView(
                    title: helperText,
                    systemImage: helperText.contains("created") ? "checkmark.circle.fill" : "info.circle.fill",
                    tone: helperText.contains("created") ? .success : .info
                )
            }
        } footer: {
            MiloPanelFooterView(
                message: "MILO understands simple English and Indonesian commands.",
                statusTitle: "Local Only",
                statusTone: .success
            )
        }
    }

    private func submit() {
        let text = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        if let parsed = try? TodoCommandParser.parse(text) {
            let todo = todoService.addTodo(
                title: parsed.title, notes: parsed.notes,
                dueDate: parsed.dueDate, priority: parsed.priority,
                createdSource: .chat
            )
            if let dueDate = parsed.dueDate {
                let reminder = reminderService.addReminder(
                    title: parsed.title, message: parsed.title,
                    dueDate: dueDate, createdSource: .todo
                )
                todoService.attachReminder(todoID: todo.id, reminderID: reminder.id)
                ReminderNotificationService.shared.scheduleNotification(for: reminder)
                onShowBubble("Todo added with reminder.")
                helperText = "Todo + reminder created."
            } else {
                onShowBubble("Todo added.")
                helperText = "Todo created."
            }
            commandText = ""
            return
        }

        if let parsed = try? NaturalLanguageReminderParser.parse(text) {
            let reminder = reminderService.addReminder(
                title: parsed.title, message: parsed.message,
                dueDate: parsed.dueDate, createdSource: .chat
            )
            ReminderNotificationService.shared.scheduleNotification(for: reminder)
            onShowBubble("Reminder set: \(parsed.message)")
            helperText = "Reminder created."
            commandText = ""
            return
        }

        helperText = "I could not parse that yet. Try: remind me in 30 min to take a break"
    }
}