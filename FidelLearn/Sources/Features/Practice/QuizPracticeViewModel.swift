import Foundation

enum QuizMode: String, CaseIterable {
    case alphabet = "Alphabet"
    case vocabulary = "Vocabulary"
}

@MainActor
final class QuizPracticeViewModel: ObservableObject {
    @Published var mode: QuizMode = .alphabet
    @Published var session = QuizSession()
    @Published var wordSession = WordQuizSession()
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
        switch mode {
        case .alphabet:
            guard let question = session.currentQuestion else { return }
            session.selectAnswer(answer)
            let wasCorrect = answer == question.correctAnswer
            Task { await progressService.recordQuizAttempt(correct: wasCorrect) }
        case .vocabulary:
            guard let question = wordSession.currentQuestion else { return }
            wordSession.selectAnswer(answer)
            let wasCorrect = answer == question.correctAnswer
            Task { await progressService.recordQuizAttempt(correct: wasCorrect) }
        }
    }

    func loadQuiz(questionCount: Int = 10) {
        isLoading = true
        Task {
            switch mode {
            case .alphabet:
                let lessons = await lessonService.getLessons(language: "tigrinya")
                var allCharacters: [FidelCharacter] = []
                for lesson in lessons where lesson.type == .alphabet {
                    let chars = await lessonService.getFidelCharacters(lessonId: lesson.id)
                    allCharacters.append(contentsOf: chars)
                }
                session.loadQuestions(from: allCharacters, count: questionCount)
            case .vocabulary:
                let lessons = await lessonService.getLessons(language: "tigrinya")
                var allWords: [Word] = []
                for lesson in lessons where lesson.type == .vocabulary {
                    let words = await lessonService.getWords(lessonId: lesson.id)
                    allWords.append(contentsOf: words)
                }
                wordSession.loadQuestions(from: allWords, count: questionCount)
            }
            isLoading = false
        }
    }

    var isComplete: Bool {
        switch mode {
        case .alphabet: session.isComplete
        case .vocabulary: wordSession.isComplete
        }
    }

    var progress: (current: Int, total: Int) {
        switch mode {
        case .alphabet: session.progress
        case .vocabulary: wordSession.progress
        }
    }

    var score: Int {
        switch mode {
        case .alphabet: session.score
        case .vocabulary: wordSession.score
        }
    }

    var totalQuestions: Int {
        switch mode {
        case .alphabet: session.questions.count
        case .vocabulary: wordSession.questions.count
        }
    }
}
