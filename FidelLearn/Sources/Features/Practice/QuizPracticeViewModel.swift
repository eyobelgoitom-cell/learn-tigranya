import Foundation
import UIKit

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
    private let learningEventService: LearningEventServiceProtocol
    private let insightsService: InsightsServiceProtocol

    init(
        lessonService: LessonServiceProtocol = LocalLessonService(),
        progressService: ProgressServiceProtocol,
        learningEventService: LearningEventServiceProtocol,
        insightsService: InsightsServiceProtocol = LocalInsightsService()
    ) {
        self.lessonService = lessonService
        self.progressService = progressService
        self.learningEventService = learningEventService
        self.insightsService = insightsService
    }

    func submitAnswer(_ answer: String) {
        switch mode {
        case .alphabet:
            guard let question = session.currentQuestion else { return }
            session.selectAnswer(answer)
            let wasCorrect = answer == question.correctAnswer
            triggerHaptic(correct: wasCorrect)
            Task {
                await progressService.recordQuizAttempt(correct: wasCorrect)
                await learningEventService.record(LearningEvent(
                    eventType: .quizAnswer,
                    payload: [
                        "item_id": question.character.id,
                        "correct": wasCorrect ? "true" : "false",
                        "question_type": "alphabet",
                        "consonant_group": question.character.consonantGroup
                    ]
                ))
            }
        case .vocabulary:
            guard let question = wordSession.currentQuestion else { return }
            wordSession.selectAnswer(answer)
            let wasCorrect = answer == question.correctAnswer
            triggerHaptic(correct: wasCorrect)
            Task {
                await progressService.recordQuizAttempt(correct: wasCorrect)
                await learningEventService.record(LearningEvent(
                    eventType: .quizAnswer,
                    payload: [
                        "item_id": question.word.id,
                        "correct": wasCorrect ? "true" : "false",
                        "question_type": "vocabulary",
                        "lesson_id": question.word.lessonId
                    ]
                ))
            }
        }
    }

    func loadQuiz(questionCount: Int = 10, initialMode: PracticeIntent? = nil) {
        if initialMode == .weakLetters { mode = .alphabet }
        else if initialMode == .weakWords { mode = .vocabulary }
        isLoading = true
        Task {
            switch mode {
            case .alphabet:
                var characters = await insightsService.getWeakCharacters(limit: 20)
                if initialMode != .weakLetters || characters.isEmpty {
                    characters = []
                    let lessons = await lessonService.getLessons(language: "tigrinya")
                    for lesson in lessons where lesson.type == .alphabet {
                        let chars = await lessonService.getFidelCharacters(lessonId: lesson.id)
                        characters.append(contentsOf: chars)
                    }
                }
                session.loadQuestions(from: characters, count: min(questionCount, max(1, characters.count)))
            case .vocabulary:
                var words = await insightsService.getWeakWords(limit: 20)
                if initialMode != .weakWords || words.isEmpty {
                    words = []
                    let lessons = await lessonService.getLessons(language: "tigrinya")
                    for lesson in lessons where lesson.type == .vocabulary {
                        let w = await lessonService.getWords(lessonId: lesson.id)
                        words.append(contentsOf: w)
                    }
                }
                wordSession.loadQuestions(from: words, count: min(questionCount, max(1, words.count)))
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

    private func triggerHaptic(correct: Bool) {
        if correct {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
