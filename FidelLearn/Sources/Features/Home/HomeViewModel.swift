import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var streak = 0
    @Published var dailyProgress: Double = 0
    @Published var lessonsCompletedToday = 0
    @Published var dailyGoal = 3
    @Published var nextLesson: Lesson?
    @Published var recommendations: [Recommendation] = []
    @Published var isStreakAtRisk = false
    @Published var wordsLearned = 0
    @Published var totalLessons = 0
    @Published var lessonsCompleted = 0

    private let progressService: ProgressServiceProtocol
    private let lessonService: LessonServiceProtocol
    private let recommendationEngine: RecommendationEngine

    init(
        progressService: ProgressServiceProtocol = LocalProgressService(),
        lessonService: LessonServiceProtocol = LocalLessonService(),
        recommendationEngine: RecommendationEngine? = nil
    ) {
        self.progressService = progressService
        self.lessonService = lessonService
        self.recommendationEngine = recommendationEngine ?? RecommendationEngine(progressService: progressService, lessonService: lessonService)
        loadData()
    }

    func loadData() {
        Task {
            streak = await progressService.getStreak()
            let (completed, goal) = await progressService.getDailyProgress()
            lessonsCompletedToday = completed
            dailyGoal = goal
            dailyProgress = goal > 0 ? Double(completed) / Double(goal) : 0
            let lessons = await lessonService.getLessons(language: "tigrinya")
            totalLessons = lessons.count
            lessonsCompleted = await progressService.getLessonsCompleted()
            nextLesson = await getNextIncompleteLesson()
            recommendations = await recommendationEngine.getRecommendations()
            wordsLearned = await progressService.getWordsLearned()
            let hour = Calendar.current.component(.hour, from: Date())
            isStreakAtRisk = streak > 0 && completed == 0 && hour >= 18
        }
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

    /// Motivational subtext based on progress.
    var motivationalMessage: String {
        if lessonsCompletedToday >= dailyGoal && dailyGoal > 0 {
            return "You hit your goal today! 🎉"
        }
        if streak >= 7 {
            return "Amazing streak! You're building a habit."
        }
        if wordsLearned >= 50 {
            return "You've learned \(wordsLearned) words — keep going!"
        }
        if lessonsCompletedToday > 0 {
            return "\(dailyGoal - lessonsCompletedToday) more to reach your daily goal."
        }
        if streak > 0 {
            return "Keep your \(streak)-day streak alive!"
        }
        if !hasProgress {
            return "Your Tigrinya journey starts here — tap below to begin."
        }
        return "Ready to learn today?"
    }

    /// Whether user has made any progress (for first-time vs returning).
    var hasProgress: Bool {
        wordsLearned > 0 || lessonsCompletedToday > 0 || streak > 0
    }

    /// Progress teaser, e.g. "3 lessons away from completing the alphabet".
    var progressTeaser: String? {
        let remaining = totalLessons - lessonsCompleted
        guard remaining > 0, totalLessons > 0 else { return nil }
        if remaining == 1 {
            return "1 lesson left to complete the alphabet!"
        }
        return "\(remaining) lessons away from completing the alphabet"
    }
}
