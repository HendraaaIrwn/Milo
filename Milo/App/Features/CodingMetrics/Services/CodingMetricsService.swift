//
//  CodingMetricsService.swift
//  Milo
//
//  PRIVACY: MILO local coding metrics do not store source code content.
//  MILO tracks active editor, approximate project, language estimation from file extensions,
//  and Git LOC summaries. Local metrics are not uploaded.
//

import Combine
import Foundation
import OSLog

@MainActor
final class CodingMetricsService: ObservableObject {
    @Published private(set) var snapshot: CodingMetricsSnapshot

    private let storage: MiloLocalStorageService
    private let gitLOCTracker: GitLOCTracker
    private var timerTask: Task<Void, Never>?

    private var currentSession = CodingSession()
    private var lastTickAt: Date?

    private let logger = Logger(
        subsystem: "com.milo",
        category: "CodingMetrics"
    )

    init(
        storage: MiloLocalStorageService? = nil,
        gitLOCTracker: GitLOCTracker? = nil
    ) {
        self.storage = storage ?? .shared
        self.gitLOCTracker = gitLOCTracker ?? GitLOCTracker()

        let loaded = self.storage.load(
            CodingMetricsSnapshot.self,
            forKey: MiloStorageKeys.codingMetricsSnapshot,
            defaultValue: CodingMetricsSnapshot.empty()
        )

        if loaded.dateKey == CodingMetricsSnapshot.makeDateKey(Date()) {
            self.snapshot = loaded
        } else {
            self.snapshot = CodingMetricsSnapshot.empty()
        }
    }

    func start() {
        stop()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.tick()
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        save()
    }
    func resetLocalStats() {
        snapshot = CodingMetricsSnapshot.empty()
        currentSession = CodingSession()
        save()
    }

    func applyProjectActivitySnapshot(_ projectSnapshot: ProjectActivitySnapshot) {
        snapshot.topProject = projectSnapshot.activeProjectName ?? snapshot.topProject
        snapshot.topLanguage = projectSnapshot.topLanguageToday ?? snapshot.topLanguage
        snapshot.locToday = projectSnapshot.locSummary
        snapshot.lastUpdatedAt = Date()

        if let name = projectSnapshot.activeProjectName {
            currentSession.projectName = name
        }

        if let path = projectSnapshot.activeProjectPath {
            currentSession.projectPath = path
        }

        save()
    }

    func applyWakaTimeFallback(_ summary: WakaTimeSummary) {
        if snapshot.codingSecondsToday <= 0 {
            snapshot.codingSecondsToday = summary.totalSeconds
        }

        if snapshot.topProject == nil {
            snapshot.topProject = summary.topProject
        }

        if snapshot.topLanguage == nil {
            snapshot.topLanguage = summary.topLanguage
        }

        if snapshot.topEditor == nil {
            snapshot.topEditor = summary.editorUsage.max(by: { $0.value < $1.value })?.key
        }

        snapshot.lastUpdatedAt = Date()
        save()
    }

    private func tick() async {
        guard isEnabled else {
            logger.debug("CodingMetrics: disabled, skipping tick")
            return
        }

        let now = Date()

        guard let app = ActiveAppDetector.currentApp(),
              ActiveAppDetector.isCodingEditor(app)
        else {
            endCurrentSessionIfNeeded()
            return
        }

        let delta = calculateDelta(now: now)
        let watchedProjects = loadWatchedProjects()

        logger.debug("CodingMetrics tick: app=\(app.name), bundle=\(app.bundleIdentifier ?? "nil"), delta=\(delta)s, watchedProjects=\(watchedProjects.count)")

        let (project, activeInfo) = findActiveProjectWithBookmarks(from: watchedProjects)

        let changedFiles: [String]
        let loc: LOCSummary

        if let project {
            changedFiles = gitLOCTracker.changedFiles(for: project)
            loc = gitLOCTracker.totalLOC(for: project)
        } else {
            changedFiles = []
            loc = .empty
        }

        let topLanguage = LanguageEstimator.estimateTopLanguage(
            fromChangedFiles: changedFiles
        )

        logger.debug("CodingMetrics git result: project=\(activeInfo?.name ?? "nil"), language=\(topLanguage ?? "nil"), files=\(changedFiles.count), loc=+\(loc.linesAdded)/-\(loc.linesDeleted) status=\(loc.status.title)")
        print("[CodingMetrics] tick result: project=\(activeInfo?.name ?? "nil") lang=\(topLanguage ?? "nil") loc=+\(loc.linesAdded)/-\(loc.linesDeleted) status=\(loc.status.title)")

        if delta > 0 {
            updateSnapshot(
                delta: delta,
                app: app,
                project: activeInfo,
                topLanguage: topLanguage,
                loc: loc
            )
        } else if project != nil || topLanguage != nil || loc.status != .unknown {
            snapshot.topEditor = app.name
            snapshot.topProject = activeInfo?.name ?? snapshot.topProject
            snapshot.topLanguage = topLanguage ?? snapshot.topLanguage
            snapshot.locToday = loc
            snapshot.lastUpdatedAt = Date()
        }

        save()
    }

    private func calculateDelta(now: Date) -> Int {
        defer {
            lastTickAt = now
        }

        guard let lastTickAt else {
            return 0
        }

        return max(0, Int(now.timeIntervalSince(lastTickAt)))
    }

    private func updateSnapshot(
        delta: Int,
        app: ActiveAppInfo,
        project: ActiveProjectInfo?,
        topLanguage: String?,
        loc: LOCSummary
    ) {
        snapshot.dateKey = CodingMetricsSnapshot.makeDateKey(Date())
        snapshot.codingSecondsToday += delta
        snapshot.currentSessionSeconds += delta
        snapshot.topEditor = app.name
        snapshot.topProject = project?.name ?? snapshot.topProject
        snapshot.topLanguage = topLanguage ?? snapshot.topLanguage
        snapshot.locToday = loc
        snapshot.lastUpdatedAt = Date()

        updateEditorMetric(app: app, delta: delta)

        if let project {
            updateProjectMetric(project: project, delta: delta, loc: loc)
        }

        if let topLanguage {
            updateLanguageMetric(language: topLanguage, delta: delta, loc: loc)
        }
    }

    private func updateEditorMetric(app: ActiveAppInfo, delta: Int) {
        if let index = snapshot.editorMetrics.firstIndex(where: {
            $0.bundleIdentifier == app.bundleIdentifier
        }) {
            snapshot.editorMetrics[index].seconds += delta
            snapshot.editorMetrics[index].lastActiveAt = Date()
        } else {
            snapshot.editorMetrics.append(
                EditorUsageMetric(
                    editorName: app.name,
                    bundleIdentifier: app.bundleIdentifier,
                    seconds: delta
                )
            )
        }
    }

    private func updateProjectMetric(
        project: ActiveProjectInfo,
        delta: Int,
        loc: LOCSummary
    ) {
        if let index = snapshot.projectMetrics.firstIndex(where: {
            $0.projectPath == project.path
        }) {
            snapshot.projectMetrics[index].seconds += delta
            snapshot.projectMetrics[index].linesAdded = loc.linesAdded
            snapshot.projectMetrics[index].linesDeleted = loc.linesDeleted
            snapshot.projectMetrics[index].lastActiveAt = Date()
        } else {
            snapshot.projectMetrics.append(
                CodingProjectMetric(
                    projectName: project.name,
                    projectPath: project.path,
                    seconds: delta,
                    linesAdded: loc.linesAdded,
                    linesDeleted: loc.linesDeleted
                )
            )
        }
    }

    private func updateLanguageMetric(
        language: String,
        delta: Int,
        loc: LOCSummary
    ) {
        if let index = snapshot.languageMetrics.firstIndex(where: {
            $0.language == language
        }) {
            snapshot.languageMetrics[index].seconds += delta
            snapshot.languageMetrics[index].linesAdded = loc.linesAdded
            snapshot.languageMetrics[index].linesDeleted = loc.linesDeleted
        } else {
            snapshot.languageMetrics.append(
                CodingLanguageMetric(
                    language: language,
                    seconds: delta,
                    linesAdded: loc.linesAdded,
                    linesDeleted: loc.linesDeleted
                )
            )
        }
    }

    private func endCurrentSessionIfNeeded() {
        lastTickAt = nil
    }

    private func loadWatchedProjects() -> [WatchedProject] {
        storage.load(
            [WatchedProject].self,
            forKey: MiloStorageKeys.watchedProjects,
            defaultValue: []
        )
        .filter(\.isEnabled)
    }

    private func findActiveProjectWithBookmarks(
        from projects: [WatchedProject]
    ) -> (project: WatchedProject?, info: ActiveProjectInfo?) {
        let accessibleWithDates: [(WatchedProject, Date?)] = projects.compactMap { project in
            guard gitLOCTracker.canAccess(project) else {
                print("[CodingMetrics] canAccess FAILED for: \(project.name) path=\(project.path)")
                return nil
            }
            let date = gitLOCTracker.modificationDate(for: project)
            print("[CodingMetrics] canAccess OK for: \(project.name) modDate=\(date?.description ?? "nil")")
            return (project, date)
        }

        guard let selected = accessibleWithDates
            .sorted(by: { ($0.1 ?? .distantPast) > ($1.1 ?? .distantPast) })
            .first
        else {
            print("[CodingMetrics] findActiveProject: NO accessible projects found (total: \(projects.count))")
            return (nil, nil)
        }

        print("[CodingMetrics] findActiveProject: selected \(selected.0.name)")
        let info = ActiveProjectInfo(name: selected.0.name, path: selected.0.path)
        return (selected.0, info)
    }

    private var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: MiloStorageKeys.codingMetricsEnabled) == nil {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.codingMetricsEnabled)
    }

    func save() {
        storage.save(snapshot, forKey: MiloStorageKeys.codingMetricsSnapshot)
        saveTodayRecord()
    }

    private func saveTodayRecord() {
        let todayKey = CodingMetricsSnapshot.makeDateKey(Date())

        var records = storage.load(
            [DailyCodingMetricsRecord].self,
            forKey: MiloStorageKeys.dailyCodingMetricsRecords,
            defaultValue: []
        )

        let record = DailyCodingMetricsRecord(
            dateKey: todayKey,
            date: Date(),
            codingSeconds: snapshot.codingSecondsToday,
            sessionCount: snapshot.sessions.count,
            topLanguage: snapshot.topLanguage,
            topProject: snapshot.topProject,
            topEditor: snapshot.topEditor,
            locSummary: snapshot.locToday,
            languageSeconds: Dictionary(
                uniqueKeysWithValues: snapshot.languageMetrics.map {
                    ($0.language, $0.seconds)
                }
            ),
            projectSeconds: Dictionary(
                uniqueKeysWithValues: snapshot.projectMetrics.map {
                    ($0.projectName, $0.seconds)
                }
            ),
            editorSeconds: Dictionary(
                uniqueKeysWithValues: snapshot.editorMetrics.map {
                    ($0.editorName, $0.seconds)
                }
            ),
            lastUpdatedAt: Date()
        )

        if let index = records.firstIndex(where: { $0.dateKey == todayKey }) {
            records[index] = record
        } else {
            records.append(record)
        }

        records = records.sorted { $0.date > $1.date }

        // Keep recent history only for MVP, e.g. 60 days.
        records = Array(records.prefix(60))

        storage.save(records, forKey: MiloStorageKeys.dailyCodingMetricsRecords)
    }
}
