import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var streak = 0
    @Published var dailyProgress: Double = 0
    @Published var lessonsCompletedToday = 0
    @Published var dailyGoal = 3
    @Published var nextLesson: Lesson?

    private let progressService: ProgressServiceProtocol
    private let lessonService: LessonServiceProtocol

    init(
        progressService: ProgressServiceProtocol = LocalProgressService(),
        lessonService: LessonServiceProtocol = LocalLessonService()
    ) {
        self.progressService = progressService
        self.lessonService = lessonService
        loadData()
    }

    func loadData() {
        Task {
            streak = await progressService.getStreak()
            let (completed, goal) = await progressService.getDailyProgress()
            lessonsCompletedToday = completed
            dailyGoal = goal
            dailyProgress = goal > 0 ? Double(completed) / Double(goal) : 0
            nextLesson = await getNextIncompleteLesson()
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
}
