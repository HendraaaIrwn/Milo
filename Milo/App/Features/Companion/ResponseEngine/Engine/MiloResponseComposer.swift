//
//  MiloResponseComposer.swift
//  Milo
//

import Foundation

struct MiloResponseComposer {
    private let templates: [MiloResponseTemplate]

    init(templates: [MiloResponseTemplate] = MiloResponseComposer.defaultTemplates) {
        self.templates = templates
    }

    func compose(
        intent: MiloResponseIntent,
        mood: MiloResponseMood,
        context: CodingContext,
        history: MiloResponseHistory
    ) -> (templateID: String, text: String)? {
        let candidates = templates.filter { template in
            guard template.intent == intent else { return false }
            if let templateMood = template.mood, templateMood != mood { return false }
            if let minFocus = template.minFocusMinutes, context.currentFocusMinutes < minFocus { return false }
            if let maxFocus = template.maxFocusMinutes, context.currentFocusMinutes > maxFocus { return false }
            if let minToday = template.minCodingMinutesToday, context.activeCodingMinutesToday < minToday { return false }
            if let maxToday = template.maxCodingMinutesToday, context.activeCodingMinutesToday > maxToday { return false }
            if let allowedTyping = template.allowedTypingIntensities, !allowedTyping.contains(context.typingIntensity) { return false }
            if let allowedTimes = template.allowedTimesOfDay, !allowedTimes.contains(context.timeOfDay) { return false }
            return true
        }

        let nonRepeated = candidates.filter { !history.hasRecentlyShown(templateID: $0.id) }
        let finalCandidates = nonRepeated.isEmpty ? candidates : nonRepeated

        guard let selected = weightedRandom(from: finalCandidates) else { return nil }

        let resolvedText = resolveTokens(in: selected.text, context: context)
        return (selected.id, resolvedText)
    }

    private func weightedRandom(from templates: [MiloResponseTemplate]) -> MiloResponseTemplate? {
        guard !templates.isEmpty else { return nil }
        let totalWeight = templates.reduce(0) { $0 + max($1.weight, 1) }
        var random = Int.random(in: 0..<totalWeight)
        for template in templates {
            random -= max(template.weight, 1)
            if random < 0 { return template }
        }
        return templates.randomElement()
    }

    private func resolveTokens(in text: String, context: CodingContext) -> String {
        let project = context.activeProjectName ?? "your project"
        let language = context.activeLanguage ?? "code"
        let editor = context.activeEditorName ?? "your editor"
        return text
            .replacingOccurrences(of: "{project}", with: project)
            .replacingOccurrences(of: "{language}", with: language)
            .replacingOccurrences(of: "{editor}", with: editor)
            .replacingOccurrences(of: "{focusMinutes}", with: "\(context.currentFocusMinutes)")
            .replacingOccurrences(of: "{todayMinutes}", with: "\(context.activeCodingMinutesToday)")
            .replacingOccurrences(of: "{idleMinutes}", with: "\(context.idleMinutes)")
            .replacingOccurrences(of: "{todoCount}", with: "\(context.todoCount)")
            .replacingOccurrences(of: "{overdueTodoCount}", with: "\(context.overdueTodoCount)")
            .replacingOccurrences(of: "{pomodoroCount}", with: "\(context.completedPomodoroCountToday)")
            .replacingOccurrences(of: "{streakDays}", with: "\(context.codingStreakDays)")
    }
}

extension MiloResponseComposer {
    static let defaultTemplates: [MiloResponseTemplate] = [
        MiloResponseTemplate(
            id: "encourage_001",
            intent: .encourage, mood: nil,
            text: "You\u{2019}ve got {focusMinutes} minutes of focus in the bag. Keep cooking.",
            weight: 4, minFocusMinutes: 10, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "project_001",
            intent: .projectComment, mood: nil,
            text: "{project} is getting serious attention today.",
            weight: 4, minFocusMinutes: 10, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "language_001",
            intent: .languageComment, mood: nil,
            text: "{language} mode detected. Tiny wizard energy.",
            weight: 4, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "typing_001",
            intent: .typingReaction, mood: nil,
            text: "That keyboard is receiving a formal complaint.",
            weight: 3, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: [.fast], allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "typing_002",
            intent: .typingReaction, mood: nil,
            text: "Typing speed: suspiciously powerful.",
            weight: 3, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: [.fast, .normal], allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "typing_003",
            intent: .typingReaction, mood: nil,
            text: "Bro is fighting the compiler in real time.",
            weight: 3, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: [.fast], allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "break_001",
            intent: .suggestBreak, mood: nil,
            text: "{focusMinutes} minutes focused. Tiny reboot recommended.",
            weight: 5, minFocusMinutes: 60, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "break_002",
            intent: .suggestBreak, mood: nil,
            text: "Stretch before your spine files a ticket.",
            weight: 3, minFocusMinutes: 45, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "welcome_back_001",
            intent: .welcomeBack, mood: nil,
            text: "Welcome back. I guarded the bugs. They multiplied.",
            weight: 5, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "welcome_back_002",
            intent: .welcomeBack, mood: nil,
            text: "Back already? The bugs missed you for {idleMinutes} minutes.",
            weight: 3, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "todo_001",
            intent: .todoReminder, mood: nil,
            text: "Todo captured. Future-you has been notified emotionally.",
            weight: 5, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "pomodoro_001",
            intent: .pomodoroComplete, mood: nil,
            text: "Focus session complete. Stretch before your spine files a ticket.",
            weight: 5, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "pomodoro_002",
            intent: .pomodoroComplete, mood: nil,
            text: "Pomodoro #{pomodoroCount} done. That\u{2019}s {todayMinutes} minutes today.",
            weight: 4, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "late_night_001",
            intent: .lateNightCheck, mood: nil,
            text: "Late-night coding detected. Powerful, but suspicious.",
            weight: 4, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: [.lateNight]
        ),
        MiloResponseTemplate(
            id: "celebrate_001",
            intent: .celebrateProgress, mood: nil,
            text: "{todayMinutes} minutes today. That is not nothing, boss.",
            weight: 4, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: 60, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "light_roast_001",
            intent: .lightRoast, mood: nil,
            text: "You call it refactor, Git calls it crime scene.",
            weight: 3, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: [.fast, .normal], allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "light_roast_002",
            intent: .lightRoast, mood: nil,
            text: "Bro is fighting semicolons like a final boss.",
            weight: 3, minFocusMinutes: nil, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: [.fast], allowedTimesOfDay: nil
        ),
        MiloResponseTemplate(
            id: "focus_001",
            intent: .focusReminder, mood: nil,
            text: "{focusMinutes} minutes in {project}. The zone is real.",
            weight: 4, minFocusMinutes: 30, maxFocusMinutes: nil,
            minCodingMinutesToday: nil, maxCodingMinutesToday: nil,
            allowedTypingIntensities: nil, allowedTimesOfDay: nil
        ),
    ]
}
