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

@MainActor
final class CodingMetricsService: ObservableObject {
    @Published private(set) var snapshot: CodingMetricsSnapshot

    private let storage: MiloLocalStorageService
    private var timerTask: Task<Void, Never>?

    private var currentSession = CodingSession()
    private var lastTickAt: Date?

    init(storage: MiloLocalStorageService) {
        self.storage = storage

        let loaded = storage.load(
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
                await MainActor.run {
                    self?.tick()
                }

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

    private func tick() {
        guard isEnabled else { return }

        let now = Date()

        guard let app = ActiveAppDetector.currentApp(),
              ActiveAppDetector.isCodingEditor(app)
        else {
            endCurrentSessionIfNeeded()
            return
        }

        let delta = calculateDelta(now: now)
        guard delta > 0 else { return }

        let projectPaths = loadProjectPaths()
        let project = ActiveProjectDetector.detectProject(from: projectPaths)

        let changedFiles = project.map {
            GitLOCTracker.changedFiles(projectPath: $0.path)
        } ?? []

        let topLanguage = LanguageEstimator.estimateTopLanguage(
            fromChangedFiles: changedFiles
        )

        let loc = project.map {
            GitLOCTracker.totalLOCToday(projectPath: $0.path)
        } ?? .empty

        updateSnapshot(
            delta: delta,
            app: app,
            project: project,
            topLanguage: topLanguage,
            loc: loc
        )

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

    private func loadProjectPaths() -> [String] {
        storage.load(
            [String].self,
            forKey: MiloStorageKeys.localProjectPaths,
            defaultValue: []
        )
    }

    private var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: MiloStorageKeys.codingMetricsEnabled) == nil {
            return true
        }

        return UserDefaults.standard.bool(forKey: MiloStorageKeys.codingMetricsEnabled)
    }

    func save() {
        storage.save(snapshot, forKey: MiloStorageKeys.codingMetricsSnapshot)
    }
}
