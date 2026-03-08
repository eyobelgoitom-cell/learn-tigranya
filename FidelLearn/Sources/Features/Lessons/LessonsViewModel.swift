import Foundation
import Combine

@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var lessonSections: [LessonSection] = []
    @Published var selectedLesson: Lesson?
    @Published var isLoading = false
    @Published var lessonProgress: [String: LessonProgress] = [:]

    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol

    init(
        lessonService: LessonServiceProtocol = LocalLessonService(),
        progressService: ProgressServiceProtocol = LocalProgressService()
    ) {
        self.lessonService = lessonService
        self.progressService = progressService
        loadLessons()
    }

    func loadLessons() {
        isLoading = true
        Task {
            lessonSections = await lessonService.getLessonSections()
            await loadProgressForLessons()
            isLoading = false
        }
    }

    func refreshProgress() {
        Task {
            await loadProgressForLessons()
        }
    }

    func progress(for lessonId: String) -> LessonProgress? {
        lessonProgress[lessonId]
    }

    func selectLesson(_ lesson: Lesson) {
        selectedLesson = lesson
    }

    private func loadProgressForLessons() async {
        var progress: [String: LessonProgress] = [:]
        for section in lessonSections {
            for lesson in section.lessons {
                if let p = await progressService.getLessonProgress(lessonId: lesson.id) {
                    progress[lesson.id] = p
                }
            }
        }
        lessonProgress = progress
    }
}
