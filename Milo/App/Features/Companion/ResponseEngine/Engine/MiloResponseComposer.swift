//
//  MiloResponseComposer.swift
//  Milo
//

import Foundation

private func t(
    _ id: String,
    _ intent: MiloResponseIntent,
    _ text: String,
    weight: Int = 3,
    mood: MiloResponseMood? = nil,
    minFocus: Int? = nil,
    maxFocus: Int? = nil,
    minToday: Int? = nil,
    maxToday: Int? = nil,
    typing: [TypingIntensity]? = nil,
    time: [TimeOfDay]? = nil
) -> MiloResponseTemplate {
    MiloResponseTemplate(
        id: id,
        intent: intent,
        mood: mood,
        text: text,
        weight: weight,
        minFocusMinutes: minFocus,
        maxFocusMinutes: maxFocus,
        minCodingMinutesToday: minToday,
        maxCodingMinutesToday: maxToday,
        allowedTypingIntensities: typing,
        allowedTimesOfDay: time
    )
}

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

        let boosted = candidates.map { template -> (MiloResponseTemplate, Int) in
            var boost = 0
            if context.activeProjectName != nil, template.intent == .projectComment { boost += 2 }
            if context.activeLanguage != nil, template.intent == .languageComment { boost += 2 }
            if context.currentFocusMinutes >= 60, template.intent == .suggestBreak { boost += 2 }
            if context.completedPomodoroCountToday > 0, template.intent == .pomodoroComplete { boost += 1 }
            if context.overdueTodoCount > 0, template.intent == .todoReminder { boost += 1 }
            if context.overdueTodoCount > 0, template.intent == .reminderDue { boost += 1 }
            if context.typingIntensity == .fast, template.intent == .typingReaction { boost += 2 }
            let effectiveWeight = max(template.weight + boost, 1)
            return (template, effectiveWeight)
        }

        let nonRepeated = boosted.filter { !history.hasRecentlyShown(templateID: $0.0.id) }
        var finalCandidates = nonRepeated.isEmpty ? boosted : nonRepeated

        if finalCandidates.count > 3 && history.consecutiveSameIntentCount >= 3 {
            finalCandidates = finalCandidates.filter { $0.0.intent != history.lastIntent }
        }
        if finalCandidates.isEmpty { finalCandidates = nonRepeated.isEmpty ? boosted : nonRepeated }

        guard let selected = weightedRandom(from: finalCandidates) else { return nil }
        let resolvedText = resolveTokens(in: selected.text, context: context)
        return (selected.id, resolvedText)
    }

    private func weightedRandom(from templates: [(MiloResponseTemplate, Int)]) -> MiloResponseTemplate? {
        guard !templates.isEmpty else { return nil }
        let totalWeight = templates.reduce(0) { $0 + $1.1 }
        var random = Int.random(in: 0..<totalWeight)
        for (template, weight) in templates {
            random -= weight
            if random < 0 { return template }
        }
        return templates.randomElement()?.0
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

// MARK: - Default Templates

extension MiloResponseComposer {

    static let defaultTemplates: [MiloResponseTemplate] =
        encourageTemplates +
        lightRoastTemplates +
        typingReactionTemplates +
        breakSuggestionTemplates +
        focusReminderTemplates +
        welcomeBackTemplates +
        todoTemplates +
        reminderTemplates +
        pomodoroTemplates +
        projectTemplates +
        languageTemplates +
        lateNightTemplates +
        dailyMilestoneTemplates +
        idleNudgeTemplates +
        overworkedTemplates

    // MARK: Encourage (15)

    private static let encourageTemplates: [MiloResponseTemplate] = [
        t("encourage_001", .encourage, "You\u{2019}ve got {focusMinutes} minutes of focus in the bag. Keep cooking.", weight: 4, minFocus: 10),
        t("encourage_002", .encourage, "{project} is getting real attention today.", weight: 4, minFocus: 10),
        t("encourage_003", .encourage, "Tiny progress is still progress. Very sneaky. Very powerful.", weight: 3),
        t("encourage_004", .encourage, "You\u{2019}re building momentum. I can smell the commits.", weight: 3),
        t("encourage_005", .encourage, "{focusMinutes} minutes focused. The tiny council approves.", weight: 3, minFocus: 15),
        t("encourage_006", .encourage, "Steady pace. No drama. Suspiciously professional.", weight: 2),
        t("encourage_007", .encourage, "Good rhythm. Keep the bugs under emotional pressure.", weight: 3),
        t("encourage_008", .encourage, "That\u{2019}s real focus. Tiny hat tip from MILO.", weight: 3, minFocus: 20),
        t("encourage_009", .encourage, "Your future self might actually thank you for this.", weight: 2),
        t("encourage_010", .encourage, "Code is moving. That counts. I checked.", weight: 3),
        t("encourage_011", .encourage, "One small fix at a time. Very dangerous behavior.", weight: 3),
        t("encourage_012", .encourage, "You\u{2019}re not stuck. You\u{2019}re buffering strategically.", weight: 2),
        t("encourage_013", .encourage, "Keep going. The compiler fears consistency.", weight: 3),
        t("encourage_014", .encourage, "{todayMinutes} minutes today. Respectfully, that is not nothing.", weight: 3, minToday: 30),
        t("encourage_015", .encourage, "Quiet focus detected. Tiny companion standing guard.", weight: 3),
    ]

    // MARK: Light Roast (15)

    private static let lightRoastTemplates: [MiloResponseTemplate] = [
        t("roast_001", .lightRoast, "That keyboard is receiving a formal complaint.", weight: 3, typing: [.fast]),
        t("roast_002", .lightRoast, "Typing speed: suspiciously powerful.", weight: 3, typing: [.fast]),
        t("roast_003", .lightRoast, "You\u{2019}re coding like the deadline just entered the room.", weight: 3, typing: [.fast]),
        t("roast_004", .lightRoast, "The bug blinked first. Probably.", weight: 3),
        t("roast_005", .lightRoast, "This is either genius or panic. I support both.", weight: 3),
        t("roast_006", .lightRoast, "SwiftUI saw that and got nervous.", weight: 2, typing: [.normal, .fast]),
        t("roast_007", .lightRoast, "So many keystrokes. So little mercy.", weight: 2, typing: [.fast]),
        t("roast_008", .lightRoast, "The compiler has entered its villain arc.", weight: 2),
        t("roast_009", .lightRoast, "You and this bug have unresolved lore.", weight: 3),
        t("roast_010", .lightRoast, "Bold strategy. Let\u{2019}s see if Xcode agrees.", weight: 3),
        t("roast_011", .lightRoast, "That refactor looked personal.", weight: 3),
        t("roast_012", .lightRoast, "MILO noticed the chaos. MILO respects it.", weight: 2),
        t("roast_013", .lightRoast, "The codebase is pretending to be calm.", weight: 2),
        t("roast_014", .lightRoast, "You\u{2019}re negotiating with pixels again, huh?", weight: 2),
        t("roast_015", .lightRoast, "Tiny roast: hydrate before fighting another VStack.", weight: 2, minFocus: 45),
    ]

    // MARK: Typing Reaction (15)

    private static let typingReactionTemplates: [MiloResponseTemplate] = [
        t("typing_001", .typingReaction, "Keyboard activity detected. Very dramatic.", weight: 3, typing: [.normal, .fast]),
        t("typing_002", .typingReaction, "The keys are fighting for their lives.", weight: 3, typing: [.fast]),
        t("typing_003", .typingReaction, "High typing energy. Tiny applause.", weight: 3, typing: [.fast]),
        t("typing_004", .typingReaction, "That sounds like either progress or panic.", weight: 3, typing: [.fast]),
        t("typing_005", .typingReaction, "You\u{2019}re typing like the bug insulted your family.", weight: 2, typing: [.fast]),
        t("typing_006", .typingReaction, "Good rhythm. Keep the flow alive.", weight: 3, typing: [.normal, .fast]),
        t("typing_007", .typingReaction, "Typing burst detected. MILO is impressed and slightly afraid.", weight: 2, typing: [.fast]),
        t("typing_008", .typingReaction, "The keyboard has become a percussion instrument.", weight: 2, typing: [.fast]),
        t("typing_009", .typingReaction, "That was a serious burst. Did the solution arrive?", weight: 3, typing: [.fast]),
        t("typing_010", .typingReaction, "Momentum detected. Protect it like a rare bug-free build.", weight: 3, typing: [.normal, .fast]),
        t("typing_011", .typingReaction, "Steady typing. Tiny engine is running.", weight: 3, typing: [.normal]),
        t("typing_012", .typingReaction, "Fast hands. Hopefully accurate hands.", weight: 2, typing: [.fast]),
        t("typing_013", .typingReaction, "A burst of confidence. Or semicolons. Hard to know.", weight: 2, typing: [.fast]),
        t("typing_014", .typingReaction, "The code is moving. The chair remains unpaid.", weight: 2, typing: [.normal, .fast]),
        t("typing_015", .typingReaction, "Keyboard says: please be gentle. MILO says: continue.", weight: 2, typing: [.fast]),
    ]

    // MARK: Break Suggestion (15)

    private static let breakSuggestionTemplates: [MiloResponseTemplate] = [
        t("break_001", .suggestBreak, "{focusMinutes} minutes focused. Tiny reboot recommended.", weight: 5, minFocus: 60),
        t("break_002", .suggestBreak, "You\u{2019}ve been locked in for {focusMinutes} minutes. Water break?", weight: 5, minFocus: 60),
        t("break_003", .suggestBreak, "Tiny reminder: your spine is also part of the team.", weight: 4, minFocus: 75),
        t("break_004", .suggestBreak, "Brain cache may need clearing. Short break suggested.", weight: 4, minFocus: 75),
        t("break_005", .suggestBreak, "Pause for one minute. The bugs can wait menacingly.", weight: 3, minFocus: 60),
        t("break_006", .suggestBreak, "{focusMinutes} minutes in. Stretch before becoming furniture.", weight: 4, minFocus: 80),
        t("break_007", .suggestBreak, "The code will survive a water break. Probably.", weight: 3, minFocus: 60),
        t("break_008", .suggestBreak, "You\u{2019}re deep in focus. Don\u{2019}t forget the human body DLC.", weight: 3, minFocus: 90),
        t("break_009", .suggestBreak, "Tiny health check: blink twice. Maybe drink water once.", weight: 3, minFocus: 70),
        t("break_010", .suggestBreak, "Long focus detected. MILO recommends a tiny reset.", weight: 4, minFocus: 60),
        t("break_011", .suggestBreak, "Your brain has been rendering for {focusMinutes} minutes.", weight: 3, minFocus: 90),
        t("break_012", .suggestBreak, "Take a short break before the code starts speaking Latin.", weight: 2, minFocus: 100),
        t("break_013", .suggestBreak, "One minute away from the screen. Tiny command, big value.", weight: 3, minFocus: 60),
        t("break_014", .suggestBreak, "MILO detected heroic focus. Hero needs water.", weight: 4, minFocus: 75),
        t("break_015", .suggestBreak, "Step back for a second. Sometimes bugs fear distance.", weight: 3, minFocus: 60),
    ]

    // MARK: Focus Reminder (10)

    private static let focusReminderTemplates: [MiloResponseTemplate] = [
        t("focus_001", .focusReminder, "{focusMinutes} minutes in {project}. The zone is real.", weight: 4, minFocus: 30),
        t("focus_002", .focusReminder, "Deep focus mode. Tiny fuzzy guardian engaged.", weight: 3, minFocus: 30),
        t("focus_003", .focusReminder, "You\u{2019}re in it now. MILO will guard periphery.", weight: 3, minFocus: 20),
        t("focus_004", .focusReminder, "Focus warp active. Reality outside {project} is optional.", weight: 3, minFocus: 45),
        t("focus_005", .focusReminder, "The concentration is almost visible. Very tiny. Very dense.", weight: 2, minFocus: 60),
        t("focus_006", .focusReminder, "Locked in. MILO is just a quiet floater in your peripheral.", weight: 3, minFocus: 30),
        t("focus_007", .focusReminder, "{focusMinutes} minutes deep. The world can wait.", weight: 4, minFocus: 45),
        t("focus_008", .focusReminder, "Focus detected. Tiny productivity field deployed.", weight: 3, minFocus: 20),
        t("focus_009", .focusReminder, "Steady focus on {project}. That\u{2019}s good energy.", weight: 3, minFocus: 30),
        t("focus_010", .focusReminder, "The focus is strong with this one. Keep it.", weight: 2, minFocus: 45),
    ]

    // MARK: Welcome Back (12)

    private static let welcomeBackTemplates: [MiloResponseTemplate] = [
        t("welcome_001", .welcomeBack, "Welcome back. I guarded the bugs. They multiplied.", weight: 5),
        t("welcome_002", .welcomeBack, "Back already? The code missed your chaos.", weight: 4),
        t("welcome_003", .welcomeBack, "Welcome back. {project} has been waiting dramatically.", weight: 4),
        t("welcome_004", .welcomeBack, "You were gone {idleMinutes} minutes. The bugs got comfortable.", weight: 4),
        t("welcome_005", .welcomeBack, "Tiny companion reporting: nothing exploded. Probably.", weight: 3),
        t("welcome_006", .welcomeBack, "Welcome back. Let\u{2019}s pretend we remember where we left off.", weight: 3),
        t("welcome_007", .welcomeBack, "Return detected. MILO has resumed judgment mode.", weight: 3),
        t("welcome_008", .welcomeBack, "The cursor moved. Hope has returned.", weight: 3),
        t("welcome_009", .welcomeBack, "Back from the void. Very cinematic.", weight: 2),
        t("welcome_010", .welcomeBack, "Welcome back. The codebase tried to act innocent.", weight: 3),
        t("welcome_011", .welcomeBack, "Nice comeback. Let\u{2019}s find the thread again.", weight: 3),
        t("welcome_012", .welcomeBack, "You\u{2019}re back. MILO kept your focus warm.", weight: 2),
    ]

    // MARK: Todo (12)

    private static let todoTemplates: [MiloResponseTemplate] = [
        t("todo_001", .todoReminder, "Todo captured. Future-you has been notified emotionally.", weight: 5),
        t("todo_002", .todoReminder, "Saved. That task is now officially someone\u{2019}s problem.", weight: 4),
        t("todo_003", .todoReminder, "Todo added. Tiny paperwork complete.", weight: 4),
        t("todo_004", .todoReminder, "Task saved. MILO will stare at it responsibly.", weight: 3),
        t("todo_005", .todoReminder, "Added to the list. The list grows stronger.", weight: 3),
        t("todo_006", .todoReminder, "Todo secured. No task left behind.", weight: 3),
        t("todo_007", .todoReminder, "Captured. Your brain may now release that tab.", weight: 4),
        t("todo_008", .todoReminder, "Task stored. Tiny admin goblin satisfied.", weight: 2),
        t("todo_009", .todoReminder, "{todoCount} active todos. Manageable chaos.", weight: 3),
        t("todo_010", .todoReminder, "Noted. Future-you gets a tiny quest.", weight: 3),
        t("todo_011", .todoReminder, "Todo added. Productivity cosplay intensifies.", weight: 2),
        t("todo_012", .todoReminder, "Saved. MILO has entered responsible mode.", weight: 3),
    ]

    // MARK: Reminder (10)

    private static let reminderTemplates: [MiloResponseTemplate] = [
        t("reminder_001", .reminderDue, "Reminder time. Tiny bell, big responsibility.", weight: 5),
        t("reminder_002", .reminderDue, "MILO reminder: this task has entered the room.", weight: 4),
        t("reminder_003", .reminderDue, "Psst. Reminder due. Don\u{2019}t make me meow twice.", weight: 4),
        t("reminder_004", .reminderDue, "Reminder triggered. The tiny system works.", weight: 3),
        t("reminder_005", .reminderDue, "Time\u{2019}s up. Past-you sent this quest.", weight: 4),
        t("reminder_006", .reminderDue, "Tiny alarm says: it is now o\u{2019}clock.", weight: 2),
        t("reminder_007", .reminderDue, "Reminder due. Future-you became present-you.", weight: 3),
        t("reminder_008", .reminderDue, "MILO gently taps the glass. Reminder time.", weight: 3),
        t("reminder_009", .reminderDue, "This reminder has matured. Like cheese. Act now.", weight: 2),
        t("reminder_010", .reminderDue, "Task resurfaced. Dramatic timing, honestly.", weight: 3),
    ]

    // MARK: Pomodoro (10)

    private static let pomodoroTemplates: [MiloResponseTemplate] = [
        t("pomodoro_001", .pomodoroComplete, "Focus session complete. Stretch before your spine files a ticket.", weight: 5),
        t("pomodoro_002", .pomodoroComplete, "Pomodoro done. Tiny victory tomato achieved.", weight: 4),
        t("pomodoro_003", .pomodoroComplete, "Session complete. The focus goblin is pleased.", weight: 4),
        t("pomodoro_004", .pomodoroComplete, "You finished a focus block. MILO salutes softly.", weight: 4),
        t("pomodoro_005", .pomodoroComplete, "Pomodoro complete. Break mode is not optional-ish.", weight: 3),
        t("pomodoro_006", .pomodoroComplete, "{pomodoroCount} sessions today. That\u{2019}s real discipline.", weight: 3),
        t("pomodoro_007", .pomodoroComplete, "Timer done. Your brain may now exhale.", weight: 4),
        t("pomodoro_008", .pomodoroComplete, "Focus block cleared. Tiny achievement unlocked.", weight: 3),
        t("pomodoro_009", .pomodoroComplete, "Pomodoro complete. Go blink like a premium user.", weight: 2),
        t("pomodoro_010", .pomodoroComplete, "Session wrapped. The code survived.", weight: 3),
    ]

    // MARK: Project Comment (10)

    private static let projectTemplates: [MiloResponseTemplate] = [
        t("project_001", .projectComment, "{project} is getting serious attention today.", weight: 4, minFocus: 10),
        t("project_002", .projectComment, "{project} is slowly becoming real. Dangerous.", weight: 3, minFocus: 20),
        t("project_003", .projectComment, "You and {project} have history now.", weight: 3, minFocus: 30),
        t("project_004", .projectComment, "{project} just got another tiny push forward.", weight: 4),
        t("project_005", .projectComment, "Working on {project}. The plot thickens.", weight: 3),
        t("project_006", .projectComment, "{project} has entered today\u{2019}s main character arc.", weight: 3),
        t("project_007", .projectComment, "Another minute invested in {project}. Compound interest, but nerdy.", weight: 2, minFocus: 20),
        t("project_008", .projectComment, "{project} is being gently bullied into existence.", weight: 3),
        t("project_009", .projectComment, "Tiny progress on {project}. Still counts.", weight: 3),
        t("project_010", .projectComment, "{project} saw your effort. No comment from the bugs.", weight: 2),
    ]

    // MARK: Language Comment (12)

    private static let languageTemplates: [MiloResponseTemplate] = [
        t("language_001", .languageComment, "{language} mode detected. Tiny wizard energy.", weight: 4),
        t("language_002", .languageComment, "{language} today. Brave choice. Respect.", weight: 3),
        t("language_003", .languageComment, "{language} is behaving suspiciously well.", weight: 3),
        t("language_004", .languageComment, "The {language} files are awake.", weight: 3),
        t("language_005", .languageComment, "{language} detected. MILO adjusts tiny glasses.", weight: 2),
        t("language_006", .languageComment, "Ah yes, {language}. Elegant chaos.", weight: 3),
        t("language_007", .languageComment, "{language} flow detected. Keep it smooth.", weight: 3),
        t("language_008", .languageComment, "{language} and focus. A dangerous combination.", weight: 3),
        t("language_009", .languageComment, "MILO sees {language}. MILO prepares emotional support.", weight: 2),
        t("language_010", .languageComment, "{language} is getting handled today.", weight: 3),
        t("language_011", .languageComment, "The {language} gods demand clean naming.", weight: 2),
        t("language_012", .languageComment, "{language} detected. Tiny compile prayers initiated.", weight: 2),
    ]

    // MARK: Late Night (10)

    private static let lateNightTemplates: [MiloResponseTemplate] = [
        t("late_001", .lateNightCheck, "Late-night coding detected. Powerful, but suspicious.", weight: 4, time: [.lateNight]),
        t("late_002", .lateNightCheck, "It\u{2019}s late. The bugs are nocturnal now.", weight: 3, time: [.lateNight]),
        t("late_003", .lateNightCheck, "Midnight brain is either genius or soup. Proceed carefully.", weight: 3, time: [.lateNight]),
        t("late_004", .lateNightCheck, "Late session detected. Tiny concern activated.", weight: 3, time: [.lateNight]),
        t("late_005", .lateNightCheck, "Night coding arc unlocked. Hydration required.", weight: 3, time: [.lateNight]),
        t("late_006", .lateNightCheck, "The clock says sleep. The code says one more fix.", weight: 3, time: [.lateNight]),
        t("late_007", .lateNightCheck, "Late-night {language}. That\u{2019}s advanced wizard behavior.", weight: 2, time: [.lateNight]),
        t("late_008", .lateNightCheck, "MILO supports ambition. MILO also supports sleep.", weight: 3, time: [.lateNight]),
        t("late_009", .lateNightCheck, "Careful. After midnight, all bugs gain +2 defense.", weight: 2, time: [.lateNight]),
        t("late_010", .lateNightCheck, "Tiny check-in: are we coding or spiraling?", weight: 2, time: [.lateNight]),
    ]

    // MARK: Daily Milestone (10)

    private static let dailyMilestoneTemplates: [MiloResponseTemplate] = [
        t("milestone_001", .celebrateProgress, "{todayMinutes} minutes today. That is not nothing, boss.", weight: 4, minToday: 60),
        t("milestone_002", .celebrateProgress, "{todayMinutes} minutes of coding today. Tiny trophy unlocked.", weight: 4, minToday: 60),
        t("milestone_003", .celebrateProgress, "You crossed {todayMinutes} minutes today. MILO noticed.", weight: 3, minToday: 90),
        t("milestone_004", .celebrateProgress, "Today\u{2019}s focus stack is getting taller.", weight: 3, minToday: 60),
        t("milestone_005", .celebrateProgress, "{todayMinutes} minutes in. Real effort detected.", weight: 4, minToday: 45),
        t("milestone_006", .celebrateProgress, "The day has receipts: {todayMinutes} coding minutes.", weight: 3, minToday: 90),
        t("milestone_007", .celebrateProgress, "Tiny milestone reached. No confetti, just respect.", weight: 3, minToday: 60),
        t("milestone_008", .celebrateProgress, "{streakDays} day streak. The tiny streak goblin is pleased.", weight: 3),
        t("milestone_009", .celebrateProgress, "That\u{2019}s a solid coding block today. Not imaginary productivity.", weight: 3, minToday: 60),
        t("milestone_010", .celebrateProgress, "Progress logged. The scoreboard is becoming real.", weight: 3, minToday: 45),
    ]

    // MARK: Idle Nudge (10)

    private static let idleNudgeTemplates: [MiloResponseTemplate] = [
        t("idle_001", .idleNudge, "Tiny nudge: still with me?", weight: 3),
        t("idle_002", .idleNudge, "The cursor has entered meditation mode.", weight: 3),
        t("idle_003", .idleNudge, "No pressure. Just a tiny productivity ghost checking in.", weight: 2),
        t("idle_004", .idleNudge, "{idleMinutes} minutes idle. Strategic pause or snack quest?", weight: 3),
        t("idle_005", .idleNudge, "MILO is patiently floating. Very professionally.", weight: 2),
        t("idle_006", .idleNudge, "The code waits. Dramatically.", weight: 3),
        t("idle_007", .idleNudge, "Tiny check: continue, break, or stare into the void?", weight: 2),
        t("idle_008", .idleNudge, "Idle detected. MILO has begun orbiting your focus.", weight: 2),
        t("idle_009", .idleNudge, "Need a reset? Tiny companion approves.", weight: 3),
        t("idle_010", .idleNudge, "Silence from the keyboard. Suspicious, but peaceful.", weight: 2),
    ]

    // MARK: Overworked (10)

    private static let overworkedTemplates: [MiloResponseTemplate] = [
        t("overworked_001", .suggestBreak, "{focusMinutes} minutes focused. That\u{2019}s heroic. Also illegal to your neck.", weight: 5, mood: .overworked, minFocus: 120),
        t("overworked_002", .suggestBreak, "Two hours in. Your brain deserves a tiny reboot.", weight: 5, mood: .overworked, minFocus: 120),
        t("overworked_003", .suggestBreak, "MILO detected overfocus. Please stand before becoming a desk ornament.", weight: 4, mood: .overworked, minFocus: 120),
        t("overworked_004", .suggestBreak, "You\u{2019}ve been locked in too long. Break first, brilliance later.", weight: 4, mood: .overworked, minFocus: 120),
        t("overworked_005", .suggestBreak, "Your focus is impressive. Your posture may disagree.", weight: 4, mood: .overworked, minFocus: 100),
        t("overworked_006", .suggestBreak, "Tiny emergency: water, stretch, blink. In any order.", weight: 4, mood: .overworked, minFocus: 100),
        t("overworked_007", .suggestBreak, "Long session detected. Even MILO\u{2019}s pixels need a nap.", weight: 3, mood: .overworked, minFocus: 120),
        t("overworked_008", .suggestBreak, "The code will still be weird after a break. Promise.", weight: 3, mood: .overworked, minFocus: 120),
        t("overworked_009", .suggestBreak, "You\u{2019}re deep in it. Step out for one minute.", weight: 4, mood: .overworked, minFocus: 100),
        t("overworked_010", .suggestBreak, "Overfocus detected. Tiny intervention initiated.", weight: 4, mood: .overworked, minFocus: 120),
    ]
}
