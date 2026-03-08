import Foundation

@MainActor
final class QuizPracticeViewModel: ObservableObject {
    @Published var session = QuizSession()
    @Published var isLoading = false

    private let lessonService: LessonServiceProtocol

    init(lessonService: LessonServiceProtocol = LocalLessonService()) {
        self.lessonService = lessonService
    }

    func loadQuiz(questionCount: Int = 10) {
        isLoading = true
        Task {
            let lessons = await lessonService.getLessons(language: "tigrinya")
            var allCharacters: [FidelCharacter] = []
            for lesson in lessons where lesson.type == .alphabet {
                let chars = await lessonService.getFidelCharacters(lessonId: lesson.id)
                allCharacters.append(contentsOf: chars)
            }
            session.loadQuestions(from: allCharacters, count: questionCount)
            isLoading = false
        }
    }
}
