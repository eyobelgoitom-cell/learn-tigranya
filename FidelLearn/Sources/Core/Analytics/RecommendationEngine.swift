import Foundation

/// A smart recommendation for the Home feed.
struct Recommendation: Identifiable {
    let id: String
    let priority: Priority
    let title: String
    let subtitle: String?
    let action: RecommendationAction

    enum Priority: Int, Comparable {
        case urgent = 0
        case high = 1
        case normal = 2
        case low = 3

        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum RecommendationAction {
        case continueLesson(Lesson)
        case reviewWeakLetters
        case reviewWeakWords
        case completeDailyGoal
        case keepStreak
    }
}

/// Produces smart recommendations for the Home feed.
final class RecommendationEngine: @unchecked Sendable {
    private let progressService: ProgressServiceProtocol
    private let lessonService: LessonServiceProtocol
    private let insightsService: InsightsServiceProtocol

    init(
        progressService: ProgressServiceProtocol,
        lessonService: LessonServiceProtocol = LocalLessonService(),
        insightsService: InsightsServiceProtocol = LocalInsightsService()
    ) {
        self.progressService = progressService
        self.lessonService = lessonService
        self.insightsService = insightsService
    }

    func getRecommendations() async -> [Recommendation] {
        var recs: [Recommendation] = []
        let weakChars = await insightsService.getWeakCharacters(limit: 5)
        let weakWords = await insightsService.getWeakWords(limit: 5)
        let (dailyCompleted, dailyGoal) = await progressService.getDailyProgress()
        let streak = await progressService.getStreak()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hour = calendar.component(.hour, from: Date())
        let isLateDay = hour >= 18

        if !weakChars.isEmpty {
            recs.append(Recommendation(
                id: "review-weak-letters",
                priority: .urgent,
                title: "Review weak letters",
                subtitle: "\(weakChars.count) letters need practice",
                action: .reviewWeakLetters
            ))
        }
        if !weakWords.isEmpty {
            recs.append(Recommendation(
                id: "review-weak-words",
                priority: weakChars.isEmpty ? .urgent : .high,
                title: "Review weak words",
                subtitle: "\(weakWords.count) words need practice",
                action: .reviewWeakWords
            ))
        }
        if let next = await getNextIncompleteLesson() {
            recs.append(Recommendation(
                id: "continue-\(next.id)",
                priority: .high,
                title: "Continue lesson",
                subtitle: next.title,
                action: .continueLesson(next)
            ))
        }
        // Skip daily goal rec — we already show the daily goal card above; avoids redundancy.
        if dailyCompleted < dailyGoal && recs.isEmpty {
            recs.append(Recommendation(
                id: "daily-goal",
                priority: .normal,
                title: "Start learning",
                subtitle: "Complete \(dailyGoal) lessons to reach your daily goal",
                action: .completeDailyGoal
            ))
        }
        if streak > 0 && isLateDay {
            recs.append(Recommendation(
                id: "keep-streak",
                priority: .low,
                title: "Keep your streak!",
                subtitle: "\(streak) day streak — don't break it",
                action: .keepStreak
            ))
        }
        return recs.sorted { $0.priority < $1.priority }
    }

    private func getNextIncompleteLesson() async -> Lesson? {
        let lessons = await lessonService.getLessons(language: "tigrinya")
        for lesson in lessons {
            if await progressService.getLessonProgress(lessonId: lesson.id) == nil {
                return lesson
            }
        }
        return lessons.first
    }
}
