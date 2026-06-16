//
//  FileEventDebouncer.swift
//  Milo
//
//  PRIVACY: Combines rapid file events to avoid excessive Git diff calls and UI updates.
//

import Foundation

@MainActor
final class FileEventDebouncer {
    private var task: Task<Void, Never>?
    private var pendingEvents: [ProjectFileEvent] = []

    func submit(
        events: [ProjectFileEvent],
        delayNanoseconds: UInt64 = 1_500_000_000,
        onFlush: @escaping ([ProjectFileEvent]) -> Void
    ) {
        pendingEvents.append(contentsOf: events)

        task?.cancel()

        task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: delayNanoseconds)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let self else { return }

                let eventsToFlush = self.pendingEvents
                self.pendingEvents.removeAll()

                onFlush(eventsToFlush)
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        pendingEvents.removeAll()
    }
}
