import Foundation
import SwiftUI

/// Composite progress service: local-first storage with optional Supabase sync when authenticated.
/// - saveProgress: saves to UserDefaults first, then upserts to Supabase when authenticated
/// - get methods: reads from local first, merges with Supabase when authenticated + online
final class SyncProgressService: ProgressServiceProtocol, @unchecked Sendable {
    private let local: LocalProgressService
    private let remote: ProgressService
    private let getIsAuthenticated: @Sendable () async -> Bool

    init(
        local: LocalProgressService = LocalProgressService(),
        remote: ProgressService = ProgressService(),
        getIsAuthenticated: @escaping @Sendable () async -> Bool
    ) {
        self.local = local
        self.remote = remote
        self.getIsAuthenticated = getIsAuthenticated
    }

    /// Convenience init for use with AppState; captures auth state from MainActor.
    @MainActor
    convenience init(appState: AppState) {
        self.init(getIsAuthenticated: {
            await MainActor.run { appState.isAuthenticated }
        })
    }

    func saveProgress(lessonId: String, completed: Bool, score: Double?) async {
        await local.saveProgress(lessonId: lessonId, completed: completed, score: score)
        if await getIsAuthenticated() {
            await remote.saveProgress(lessonId: lessonId, completed: completed, score: score)
        }
    }

    func getLessonProgress(lessonId: String) async -> LessonProgress? {
        let localProgress = await local.getLessonProgress(lessonId: lessonId)
        if await getIsAuthenticated() {
            let remoteProgress = await remote.getLessonProgress(lessonId: lessonId)
            return mergeLessonProgress(local: localProgress, remote: remoteProgress)
        }
        return localProgress
    }

    func getStreak() async -> Int {
        let localStreak = await local.getStreak()
        if await getIsAuthenticated() {
            let remoteStreak = await remote.getStreak()
            return max(localStreak, remoteStreak)
        }
        return localStreak
    }

    func getDailyProgress() async -> (Int, Int) {
        let localResult = await local.getDailyProgress()
        if await getIsAuthenticated() {
            let remoteResult = await remote.getDailyProgress()
            let completed = max(localResult.0, remoteResult.0)
            let goal = max(localResult.1, remoteResult.1)
            return (completed, goal)
        }
        return localResult
    }

    private func mergeLessonProgress(local: LessonProgress?, remote: LessonProgress?) -> LessonProgress? {
        if let remote = remote, let local = local {
            let remoteCompletedAt = remote.completedAt ?? .distantPast
            let localCompletedAt = local.completedAt ?? .distantPast
            return remoteCompletedAt >= localCompletedAt ? remote : local
        }
        return remote ?? local
    }
}

// MARK: - Environment

private struct ProgressServiceKey: EnvironmentKey {
    static let defaultValue: SyncProgressService = SyncProgressService(getIsAuthenticated: { false })
}

extension EnvironmentValues {
    var progressService: SyncProgressService {
        get { self[ProgressServiceKey.self] }
        set { self[ProgressServiceKey.self] = newValue }
    }
}
