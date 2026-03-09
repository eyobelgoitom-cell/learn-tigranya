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

    func getDailyProgress() async -> (completed: Int, goal: Int) {
        let localResult = await local.getDailyProgress()
        if await getIsAuthenticated() {
            let remoteResult = await remote.getDailyProgress()
            let completed = max(localResult.completed, remoteResult.completed)
            let goal = max(localResult.goal, remoteResult.goal)
            return (completed, goal)
        }
        return localResult
    }

    func getWordsLearned() async -> Int {
        let localCount = await local.getWordsLearned()
        if await getIsAuthenticated() {
            let remoteCount = await remote.getWordsLearned()
            return max(localCount, remoteCount)
        }
        return localCount
    }

    func getLessonsCompleted() async -> Int {
        let localCount = await local.getLessonsCompleted()
        if await getIsAuthenticated() {
            let remoteCount = await remote.getLessonsCompleted()
            return max(localCount, remoteCount)
        }
        return localCount
    }

    func getAccuracy() async -> Double {
        let localAccuracy = await local.getAccuracy()
        if await getIsAuthenticated() {
            let remoteAccuracy = await remote.getAccuracy()
            return max(localAccuracy, remoteAccuracy)
        }
        return localAccuracy
    }

    func getAchievements() async -> [Achievement] {
        let localAchievements = await local.getAchievements()
        if await getIsAuthenticated() {
            let remoteAchievements = await remote.getAchievements()
            return mergeAchievements(local: localAchievements, remote: remoteAchievements)
        }
        return localAchievements
    }

    func recordQuizAttempt(correct: Bool) async {
        await local.recordQuizAttempt(correct: correct)
    }

    private func mergeAchievements(local: [Achievement], remote: [Achievement]) -> [Achievement] {
        local.enumerated().map { index, localA in
            let remoteA = remote.first { $0.id == localA.id }
            let isUnlocked = localA.isUnlocked || (remoteA?.isUnlocked ?? false)
            return Achievement(
                id: localA.id,
                title: localA.title,
                description: localA.description,
                isUnlocked: isUnlocked,
                unlockedAt: localA.unlockedAt ?? remoteA?.unlockedAt
            )
        }
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
