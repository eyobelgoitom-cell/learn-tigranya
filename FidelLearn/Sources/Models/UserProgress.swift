import Foundation

/// User progress model (maps to user_progress table).
struct UserProgress: Identifiable, Codable {
    let id: String
    let userId: String
    let lessonId: String
    let completed: Bool
    let score: Double?
    let completedAt: Date?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case completed
        case score
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Lesson progress for UI display.
struct LessonProgress {
    let lessonId: String
    let isCompleted: Bool
    let score: Double?
    let completedAt: Date?
}

/// Achievement for gamification.
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let unlockedAt: Date?
}
