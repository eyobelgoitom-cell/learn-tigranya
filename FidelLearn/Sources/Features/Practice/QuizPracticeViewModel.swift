import Foundation

@MainActor
final class QuizPracticeViewModel: ObservableObject {
    @Published var session = QuizSession()
    @Published var isLoading = false

    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol

    init(
        lessonService: LessonServiceProtocol = LocalLessonService(),
        progressService: ProgressServiceProtocol
    ) {
        self.lessonService = lessonService
        self.progressService = progressService
    }

    func submitAnswer(_ answer: String) {
        guard let question = session.currentQuestion else { return }
        session.selectAnswer(answer)
        let wasCorrect = answer == question.correctAnswer
        Task {
            await progressService.recordQuizAttempt(correct: wasCorrect)
        }
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
