import Foundation
import Combine

@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var lessonSections: [LessonSection] = []
    @Published var selectedLesson: Lesson?
    @Published var isLoading = false

    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol

    init(
        lessonService: LessonServiceProtocol = LocalLessonService(),
        progressService: ProgressServiceProtocol = ProgressService()
    ) {
        self.lessonService = lessonService
        self.progressService = progressService
        loadLessons()
    }

    func loadLessons() {
        isLoading = true
        Task {
            lessonSections = await lessonService.getLessonSections()
            isLoading = false
        }
    }

    func progress(for lessonId: String) -> LessonProgress? {
        nil // TODO: Load from progress service
    }

    func selectLesson(_ lesson: Lesson) {
        selectedLesson = lesson
    }
}
