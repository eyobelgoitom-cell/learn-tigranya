import Foundation

/// Offline-first progress storage using UserDefaults. Works without auth.
/// Sync to Supabase when online (future enhancement).
final class LocalProgressService: ProgressServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let completedKey = "fidel_learn_completed_lessons"
    private let dailyCompletedKey = "fidel_learn_daily_completed"
    private let lastActivityKey = "fidel_learn_last_activity"
    private let quizStatsKey = "fidel_learn_quiz_stats"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getStreak() async -> Int {
        let lastActivity = lastActivityDate
        guard let last = lastActivity else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: last)
        let daysSince = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        if daysSince > 1 { return 0 }
        return streakCount
    }

    func getDailyProgress() async -> (completed: Int, goal: Int) {
        let (completed, _) = todayProgress
        return (completed, 3)
    }

    func getWordsLearned() async -> Int {
        // Vocabulary not yet implemented; return 0
        0
    }

    func getLessonsCompleted() async -> Int {
        completedLessonIds.count
    }

    func getAccuracy() async -> Double {
        let stats = quizStats
        guard stats.totalAttempts > 0 else { return 0 }
        return Double(stats.totalCorrect) / Double(stats.totalAttempts)
    }

    func getAchievements() async -> [Achievement] {
        let completed = completedLessonIds.count
        let streak = await getStreak()
        return [
            Achievement(
                id: "1",
                title: "First Lesson",
                description: "Complete your first lesson",
                isUnlocked: completed >= 1,
                unlockedAt: nil
            ),
            Achievement(
                id: "2",
                title: "7 Day Streak",
                description: "Learn for 7 days in a row",
                isUnlocked: streak >= 7,
                unlockedAt: nil
            ),
            Achievement(
                id: "3",
                title: "100 Words",
                description: "Learn 100 words",
                isUnlocked: false,
                unlockedAt: nil
            )
        ]
    }

    func saveProgress(lessonId: String, completed: Bool, score: Double?) async {
        guard completed else { return }
        var ids = completedLessonIds
        if !ids.contains(lessonId) {
            ids.append(lessonId)
            defaults.set(ids, forKey: completedKey)
        }
        recordDailyCompletion()
        updateLastActivity()
    }

    func getLessonProgress(lessonId: String) async -> LessonProgress? {
        guard completedLessonIds.contains(lessonId) else { return nil }
        return LessonProgress(
            lessonId: lessonId,
            isCompleted: true,
            score: nil,
            completedAt: lastActivityDate
        )
    }

    func recordQuizAttempt(correct: Bool) async {
        recordQuizAttemptInternal(correct: correct)
    }

    // MARK: - Private

    private var completedLessonIds: [String] {
        defaults.stringArray(forKey: completedKey) ?? []
    }

    private var streakCount: Int {
        defaults.integer(forKey: "fidel_learn_streak")
    }

    private var lastActivityDate: Date? {
        defaults.object(forKey: lastActivityKey) as? Date
    }

    private var quizStats: (totalCorrect: Int, totalAttempts: Int) {
        let correct = defaults.integer(forKey: "\(quizStatsKey)_correct")
        let total = defaults.integer(forKey: "\(quizStatsKey)_attempts")
        return (correct, total)
    }

    private var todayProgress: (completed: Int, date: String) {
        let key = "\(dailyCompletedKey)_\(todayString)"
        return (defaults.integer(forKey: key), todayString)
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func recordDailyCompletion() {
        let key = "\(dailyCompletedKey)_\(todayString)"
        let current = defaults.integer(forKey: key)
        defaults.set(current + 1, forKey: key)
    }

    private func updateLastActivity() {
        let now = Date()
        let previousLast = lastActivityDate
        defaults.set(now, forKey: lastActivityKey)
        updateStreak(now: now, previousLastActivity: previousLast)
    }

    private func updateStreak(now: Date, previousLastActivity: Date?) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let currentStreak = streakCount
        if let last = previousLastActivity {
            let lastDay = calendar.startOfDay(for: last)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if daysDiff == 0 { return }
            if daysDiff == 1 {
                defaults.set(currentStreak + 1, forKey: "fidel_learn_streak")
            } else {
                defaults.set(1, forKey: "fidel_learn_streak")
            }
        } else {
            defaults.set(1, forKey: "fidel_learn_streak")
        }
    }

    private func recordQuizAttemptInternal(correct: Bool) {
        let correctKey = "\(quizStatsKey)_correct"
        let totalKey = "\(quizStatsKey)_attempts"
        let c = defaults.integer(forKey: correctKey)
        let t = defaults.integer(forKey: totalKey)
        defaults.set(c + (correct ? 1 : 0), forKey: correctKey)
        defaults.set(t + 1, forKey: totalKey)
    }
}
