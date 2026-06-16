//
//  ProjectFileWatcherService.swift
//  Milo
//
//  PRIVACY: MILO File Watcher is local-only.
//  It tracks file activity metadata, file extension, language estimate, and Git LOC summary.
//  MILO does not store source code contents or upload project activity.
//  MILO ignores dependency/build/generated folders.
//

import Foundation
import Combine
import CoreServices
import OSLog

@MainActor
final class ProjectFileWatcherService: ObservableObject {
    @Published private(set) var watchedProjects: [WatchedProject] = []
    @Published private(set) var status: FileWatcherStatus = .stopped
    @Published private(set) var snapshot: ProjectActivitySnapshot = .empty()

    private let storage: MiloLocalStorageService
    private let bookmarkStore: SecurityScopedBookmarkStore
    private let gitLOCTracker: GitLOCTracker
    private let debouncer = FileEventDebouncer()
    private let logger = Logger(subsystem: "com.milo", category: "FileWatcher")

    private var streams: [UUID: FSEventStreamRef] = [:]
    private var contextBoxes: [UUID: FSEventContextBox] = [:]
    private var activeSecurityScopedURLs: [UUID: URL] = [:]

    var onProjectActivity: ((ProjectActivitySnapshot) -> Void)?
    var onFileEvents: (([ProjectFileEvent]) -> Void)?

    init(
        storage: MiloLocalStorageService = .shared,
        bookmarkStore: SecurityScopedBookmarkStore = .shared,
        gitLOCTracker: GitLOCTracker = GitLOCTracker()
    ) {
        self.storage = storage
        self.bookmarkStore = bookmarkStore
        self.gitLOCTracker = gitLOCTracker
        load()
    }

    deinit {
        for stream in streams.values {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
        streams.removeAll()

        for url in activeSecurityScopedURLs.values {
            url.stopAccessingSecurityScopedResource()
        }
        activeSecurityScopedURLs.removeAll()
        contextBoxes.removeAll()
    }

    func load() {
        watchedProjects = storage.load(
            [WatchedProject].self,
            forKey: MiloStorageKeys.watchedProjects,
            defaultValue: []
        )

        snapshot = storage.load(
            ProjectActivitySnapshot.self,
            forKey: MiloStorageKeys.projectActivitySnapshot,
            defaultValue: .empty()
        )

        if snapshot.dateKey != ProjectActivitySnapshot.makeDateKey(Date()) {
            snapshot = .empty()
            saveSnapshot()
        }
    }

    func saveProjects() {
        storage.save(watchedProjects, forKey: MiloStorageKeys.watchedProjects)
    }

    func saveSnapshot() {
        storage.save(snapshot, forKey: MiloStorageKeys.projectActivitySnapshot)
    }

    func resetActivitySnapshot() {
        snapshot = .empty()
        saveSnapshot()
    }

    func clearProjectActivityMetadata() {
        for index in watchedProjects.indices {
            watchedProjects[index].lastActivityAt = nil
            watchedProjects[index].lastKnownTopLanguage = nil
        }
        saveProjects()
    }

    func addProject(url: URL) {
        do {
            let bookmark = try bookmarkStore.createBookmark(for: url)

            var project = WatchedProject(
                name: url.lastPathComponent,
                path: url.path,
                bookmarkData: bookmark,
                isEnabled: true
            )

            let gitInfo = gitLOCTracker.detectRepository(for: project)
            project.gitRepositoryInfo = gitInfo

            if gitInfo.canTrackLOC {
                project.lastLOCSummary = gitLOCTracker.totalLOC(for: project)
            } else {
                project.lastLOCSummary = LOCSummary.unavailable(gitInfoToUnavailable(gitInfo))
            }

            watchedProjects.append(project)
            saveProjects()

            if isEnabled {
                startWatching(project)
            }
            logger.debug("Added project: \(project.name) git=\(gitInfo.status.title)")
        } catch {
            status = .error(message: "Could not add project folder.")
            logger.error("Failed to add project: \(error.localizedDescription)")
        }
    }

    func removeProject(id: UUID) {
        stopWatching(projectID: id)
        watchedProjects.removeAll { $0.id == id }
        saveProjects()

        if streams.isEmpty {
            status = .stopped
        }
    }

    func setProjectEnabled(id: UUID, isEnabled enabled: Bool) {
        guard let index = watchedProjects.firstIndex(where: { $0.id == id }) else { return }
        watchedProjects[index].isEnabled = enabled
        saveProjects()

        if enabled {
            startWatching(watchedProjects[index])
        } else {
            stopWatching(projectID: id)
        }
    }

    func start() {
        guard isEnabled else {
            status = .paused
            return
        }

        stop()

        for project in watchedProjects where project.isEnabled {
            startWatching(project)
        }

        status = streams.isEmpty ? .stopped : .running
    }

    func pause() {
        stop()
        status = .paused
    }

    func resume() {
        start()
    }

    func stop() {
        let projectIDs = Array(streams.keys)

        for id in projectIDs {
            stopWatching(projectID: id)
        }

        debouncer.cancel()
        status = .stopped
    }

    private func startWatching(_ project: WatchedProject) {
        guard streams[project.id] == nil else { return }

        let url: URL

        if let bookmarkData = project.bookmarkData {
            do {
                url = try bookmarkStore.resolveBookmark(bookmarkData)
                _ = url.startAccessingSecurityScopedResource()
                activeSecurityScopedURLs[project.id] = url
            } catch {
                logger.error("Failed to resolve bookmark for \(project.name): \(error.localizedDescription)")
                return
            }
        } else {
            url = URL(fileURLWithPath: project.path)
        }

        let contextBox = FSEventContextBox(
            watcher: self,
            projectID: project.id,
            projectName: project.name,
            projectPath: url.path
        )
        contextBoxes[project.id] = contextBox
        print("[FileWatcher] start project:", project.name)
        print("[FileWatcher] context box stored:", contextBoxes.keys.count)

        let pathsToWatch = [url.path] as CFArray

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(contextBox).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { _, info, numEvents, eventPaths, eventFlags, _ in
            guard let info else { return }
            let contextBox = Unmanaged<FSEventContextBox>.fromOpaque(info).takeUnretainedValue()
            guard let watcher = contextBox.watcher else { return }

            let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] ?? []
            print("[FileWatcher] callback fired:", paths.count)

            var flags: [FSEventStreamEventFlags] = []
            for i in 0..<numEvents { flags.append(eventFlags[i]) }

            let projectID = contextBox.projectID
            let projectName = contextBox.projectName
            let projectPath = contextBox.projectPath

            Task { @MainActor in
                watcher.handleRawEvents(
                    paths: paths,
                    flags: flags,
                    projectID: projectID,
                    projectName: projectName,
                    projectPath: projectPath
                )
            }
        }

        guard let stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.6,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagIgnoreSelf)
        ) else {
            contextBoxes.removeValue(forKey: project.id)
            if let scopedURL = activeSecurityScopedURLs[project.id] {
                scopedURL.stopAccessingSecurityScopedResource()
                activeSecurityScopedURLs.removeValue(forKey: project.id)
            }
            logger.error("Failed to create FSEvent stream for \(project.name)")
            return
        }

        FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)

        guard FSEventStreamStart(stream) else {
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            contextBoxes.removeValue(forKey: project.id)
            if let scopedURL = activeSecurityScopedURLs[project.id] {
                scopedURL.stopAccessingSecurityScopedResource()
                activeSecurityScopedURLs.removeValue(forKey: project.id)
            }
            logger.error("Failed to start FSEvent stream for \(project.name)")
            return
        }

        streams[project.id] = stream
        status = .running
        logger.debug("Watching project: \(project.name)")
    }

    private func stopWatching(projectID: UUID) {
        print("[FileWatcher] stop project:", projectID)

        guard let stream = streams[projectID] else {
            contextBoxes.removeValue(forKey: projectID)
            print("[FileWatcher] context box removed:", projectID)
            return
        }

        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)

        streams.removeValue(forKey: projectID)

        if let url = activeSecurityScopedURLs[projectID] {
            url.stopAccessingSecurityScopedResource()
            activeSecurityScopedURLs.removeValue(forKey: projectID)
        }

        contextBoxes.removeValue(forKey: projectID)
        print("[FileWatcher] context box removed:", projectID)
    }

    private func handleRawEvents(
        paths: [String],
        flags: [FSEventStreamEventFlags],
        projectID: UUID,
        projectName: String,
        projectPath: String
    ) {
        guard streams[projectID] != nil else { return }

        var events: [ProjectFileEvent] = []

        for idx in paths.indices {
            let path = paths[idx]

            guard !ProjectFolderIgnoreRules.shouldIgnore(path: path) else { continue }

            let eventType = parseEventType(flags[safe: idx] ?? 0)
            let relative = ProjectFolderIgnoreRules.relativePath(
                filePath: path,
                projectPath: projectPath
            )
            let language = LanguageEstimator.estimateLanguage(forFilePath: path)

            let event = ProjectFileEvent(
                projectID: projectID,
                projectName: projectName,
                projectPath: projectPath,
                filePath: path,
                relativePath: relative,
                eventType: eventType,
                language: language
            )
            events.append(event)
        }

        guard !events.isEmpty else { return }

        debouncer.submit(events: events) { [weak self] flushedEvents in
            self?.handleDebouncedEvents(flushedEvents)
        }
    }

    private func handleDebouncedEvents(_ events: [ProjectFileEvent]) {
        guard let last = events.last else { return }

        if let project = watchedProjects.first(where: { $0.id == last.projectID }) {
            Task {
                let loc = gitLOCTracker.totalLOC(for: project)
                let gitInfo = gitLOCTracker.detectRepository(for: project)
                await MainActor.run {
                    updateSnapshot(
                        with: events,
                        activeProjectEvent: last,
                        loc: loc,
                        project: project,
                        gitInfo: gitInfo
                    )
                }
            }
        }

        onFileEvents?(events)
    }

    private func updateSnapshot(
        with events: [ProjectFileEvent],
        activeProjectEvent: ProjectFileEvent,
        loc: LOCSummary,
        project: WatchedProject,
        gitInfo: GitRepositoryInfo
    ) {
        if snapshot.dateKey != ProjectActivitySnapshot.makeDateKey(Date()) {
            snapshot = .empty()
        }

        snapshot.activeProjectName = activeProjectEvent.projectName
        snapshot.activeProjectPath = activeProjectEvent.projectPath
        snapshot.lastActivityAt = Date()
        snapshot.changedFileCountToday += events.count
        snapshot.lastUpdatedAt = Date()

        for event in events {
            if let language = event.language {
                snapshot.recentLanguages[language, default: 0] += 1
            }
        }

        snapshot.topLanguageToday = snapshot.recentLanguages.max(by: { $0.value < $1.value })?.key
        snapshot.locSummary = loc

        snapshot.recentEvents.append(contentsOf: events)
        if snapshot.recentEvents.count > 100 {
            snapshot.recentEvents = Array(snapshot.recentEvents.suffix(100))
        }

        // Update project metadata with git and LOC info
        updateProjectGitAndLOCMetadata(
            projectID: activeProjectEvent.projectID,
            locSummary: loc,
            gitInfo: gitInfo
        )

        saveSnapshot()
        onProjectActivity?(snapshot)
    }

    private func updateProjectGitAndLOCMetadata(
        projectID: UUID,
        locSummary: LOCSummary,
        gitInfo: GitRepositoryInfo
    ) {
        guard let index = watchedProjects.firstIndex(where: { $0.id == projectID }) else {
            return
        }

        watchedProjects[index].lastActivityAt = Date()
        watchedProjects[index].lastKnownTopLanguage = snapshot.topLanguageToday
        watchedProjects[index].lastLOCSummary = locSummary
        watchedProjects[index].gitRepositoryInfo = gitInfo

        saveProjects()
    }

    func refreshGitStatus(for projectID: UUID) {
        guard let index = watchedProjects.firstIndex(where: { $0.id == projectID }) else {
            return
        }

        var project = watchedProjects[index]
        project.gitRepositoryInfo = GitRepositoryInfo(
            selectedPath: project.path,
            repoRootPath: nil,
            status: .checking,
            checkedAt: Date()
        )
        watchedProjects[index] = project
        saveProjects()

        let gitInfo = gitLOCTracker.detectRepository(for: project)
        let locSummary: LOCSummary

        if gitInfo.canTrackLOC {
            locSummary = gitLOCTracker.totalLOC(for: project)
        } else {
            locSummary = LOCSummary.unavailable(gitInfoToUnavailable(gitInfo))
        }

        watchedProjects[index].gitRepositoryInfo = gitInfo
        watchedProjects[index].lastLOCSummary = locSummary
        saveProjects()
    }

    private func gitInfoToUnavailable(_ info: GitRepositoryInfo) -> LOCSummaryStatus {
        switch info.status {
        case .notGitRepository:
            return .notGitRepository
        case .permissionDenied(let message):
            return .permissionDenied(message)
        case .gitUnavailable(let message):
            return .gitUnavailable(message)
        case .error(let message):
            return .gitError(message)
        default:
            return .unknown
        }
    }

    private func parseEventType(_ flag: FSEventStreamEventFlags) -> ProjectFileEventType {
        if flag & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated) != 0 {
            return .created
        }
        if flag & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved) != 0 {
            return .deleted
        }
        if flag & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed) != 0 {
            return .renamed
        }
        if flag & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified) != 0 {
            return .modified
        }
        return .unknown
    }

    private var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: MiloStorageKeys.fileWatcherEnabled) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: MiloStorageKeys.fileWatcherEnabled)
    }
}

// MARK: - C Callback Context

private final class FSEventContextBox {
    weak var watcher: ProjectFileWatcherService?

    let projectID: UUID
    let projectName: String
    let projectPath: String

    init(
        watcher: ProjectFileWatcherService,
        projectID: UUID,
        projectName: String,
        projectPath: String
    ) {
        self.watcher = watcher
        self.projectID = projectID
        self.projectName = projectName
        self.projectPath = projectPath
    }
}

// MARK: - Safe Array Indexing

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
