import Foundation

protocol ProgressServiceProtocol: Sendable {
    func getStreak() async -> Int
    func getDailyProgress() async -> (completed: Int, goal: Int)
    func getWordsLearned() async -> Int
    func getLessonsCompleted() async -> Int
    func getAccuracy() async -> Double
    func getAchievements() async -> [Achievement]
    func saveProgress(lessonId: String, completed: Bool, score: Double?) async
    func getLessonProgress(lessonId: String) async -> LessonProgress?
}

final class ProgressService: ProgressServiceProtocol {
    private let client = SupabaseConfig.client

    func getStreak() async -> Int {
        guard let userId = await currentUserId() else { return 0 }
        do {
            let stats: [UserStats] = try await client
                .from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            return stats.first?.currentStreak ?? 0
        } catch {
            return 0
        }
    }

    func getDailyProgress() async -> (completed: Int, goal: Int) {
        guard let userId = await currentUserId() else { return (0, 3) }
        do {
            let today = String(ISO8601DateFormatter().string(from: Date()).prefix(10))
            let progress: [UserProgress] = try await client
                .from("user_progress")
                .select()
                .eq("user_id", value: userId)
                .eq("completed", value: true)
                .gte("completed_at", value: today)
                .execute()
                .value
            return (progress.count, 3)
        } catch {
            return (0, 3)
        }
    }

    func getWordsLearned() async -> Int {
        guard let userId = await currentUserId() else { return 0 }
        do {
            let stats: [UserStats] = try await client
                .from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            return stats.first?.wordsLearned ?? 0
        } catch {
            return 0
        }
    }

    func getLessonsCompleted() async -> Int {
        guard let userId = await currentUserId() else { return 0 }
        do {
            let progress: [UserProgress] = try await client
                .from("user_progress")
                .select()
                .eq("user_id", value: userId)
                .eq("completed", value: true)
                .execute()
                .value
            return progress.count
        } catch {
            return 0
        }
    }

    func getAccuracy() async -> Double {
        guard let userId = await currentUserId() else { return 0 }
        do {
            let stats: [UserStats] = try await client
                .from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            guard let stat = stats.first, stat.totalAttempts > 0 else { return 0 }
            return Double(stat.totalCorrect) / Double(stat.totalAttempts)
        } catch {
            return 0
        }
    }

    func getAchievements() async -> [Achievement] {
        // TODO: Implement achievements from DB
        return [
            Achievement(id: "1", title: "First Lesson", description: "Complete your first lesson", isUnlocked: false, unlockedAt: nil),
            Achievement(id: "2", title: "7 Day Streak", description: "Learn for 7 days in a row", isUnlocked: false, unlockedAt: nil),
            Achievement(id: "3", title: "100 Words", description: "Learn 100 words", isUnlocked: false, unlockedAt: nil)
        ]
    }

    func getLessonProgress(lessonId: String) async -> LessonProgress? {
        guard let userId = await currentUserId() else { return nil }
        do {
            let progress: [UserProgress] = try await client
                .from("user_progress")
                .select()
                .eq("user_id", value: userId)
                .eq("lesson_id", value: lessonId)
                .execute()
                .value
            guard let p = progress.first, p.completed else { return nil }
            return LessonProgress(
                lessonId: p.lessonId,
                isCompleted: p.completed,
                score: p.score,
                completedAt: p.completedAt
            )
        } catch {
            return nil
        }
    }

    func saveProgress(lessonId: String, completed: Bool, score: Double?) async {
        guard let userId = await currentUserId() else { return }
        do {
            let record = UserProgressRecord(
                userId: userId,
                lessonId: lessonId,
                completed: completed,
                score: score,
                completedAt: completed ? Date() : nil
            )
            try await client
                .from("user_progress")
                .upsert(record, onConflict: "user_id,lesson_id")
                .execute()
        } catch {
            // Handle error
        }
    }

    private func currentUserId() async -> String? {
        try? await client.auth.session.user.id.uuidString
    }
}

private struct UserProgressRecord: Encodable {
    let userId: String
    let lessonId: String
    let completed: Bool
    let score: Double?
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case lessonId = "lesson_id"
        case completed
        case score
        case completedAt = "completed_at"
    }
}

private struct UserStats: Codable {
    let userId: String
    let wordsLearned: Int
    let lessonsCompleted: Int
    let currentStreak: Int
    let totalCorrect: Int
    let totalAttempts: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case wordsLearned = "words_learned"
        case lessonsCompleted = "lessons_completed"
        case currentStreak = "current_streak"
        case totalCorrect = "total_correct"
        case totalAttempts = "total_attempts"
    }
}
