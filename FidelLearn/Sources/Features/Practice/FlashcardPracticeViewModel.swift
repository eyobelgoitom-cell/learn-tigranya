import Foundation

enum FlashcardMode: String, CaseIterable {
    case alphabet = "Alphabet"
    case vocabulary = "Vocabulary"
}

@MainActor
final class FlashcardPracticeViewModel: ObservableObject {
    @Published var mode: FlashcardMode = .alphabet
    @Published var session = FlashcardSession()
    @Published var wordSession = WordFlashcardSession()
    @Published var isLoading = false

    private let lessonService: LessonServiceProtocol
    private let learningEventService: LearningEventServiceProtocol

    init(
        lessonService: LessonServiceProtocol = LocalLessonService(),
        learningEventService: LearningEventServiceProtocol
    ) {
        self.lessonService = lessonService
        self.learningEventService = learningEventService
    }

    func recordAndKnowIt() {
        switch mode {
        case .alphabet:
            if let card = session.currentCard {
                Task {
                    await learningEventService.record(LearningEvent(
                        eventType: .flashcardReview,
                        payload: [
                            "item_id": card.id,
                            "knew_it": "true",
                            "item_type": "fidel",
                            "consonant_group": card.consonantGroup
                        ]
                    ))
                }
            }
            session.knowIt()
        case .vocabulary:
            if let card = wordSession.currentCard {
                Task {
                    await learningEventService.record(LearningEvent(
                        eventType: .flashcardReview,
                        payload: [
                            "item_id": card.id,
                            "knew_it": "true",
                            "item_type": "word",
                            "lesson_id": card.lessonId
                        ]
                    ))
                }
            }
            wordSession.knowIt()
        }
    }

    func recordAndReviewLater() {
        switch mode {
        case .alphabet:
            if let card = session.currentCard {
                Task {
                    await learningEventService.record(LearningEvent(
                        eventType: .flashcardReview,
                        payload: [
                            "item_id": card.id,
                            "knew_it": "false",
                            "item_type": "fidel",
                            "consonant_group": card.consonantGroup
                        ]
                    ))
                }
            }
            session.reviewLater()
        case .vocabulary:
            if let card = wordSession.currentCard {
                Task {
                    await learningEventService.record(LearningEvent(
                        eventType: .flashcardReview,
                        payload: [
                            "item_id": card.id,
                            "knew_it": "false",
                            "item_type": "word",
                            "lesson_id": card.lessonId
                        ]
                    ))
                }
            }
            wordSession.reviewLater()
        }
    }

    func loadCards() {
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
                session.loadCards(from: allCharacters)
            case .vocabulary:
                let lessons = await lessonService.getLessons(language: "tigrinya")
                var allWords: [Word] = []
                for lesson in lessons where lesson.type == .vocabulary {
                    let words = await lessonService.getWords(lessonId: lesson.id)
                    allWords.append(contentsOf: words)
                }
                wordSession.loadCards(from: allWords)
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

    var knownCount: Int {
        switch mode {
        case .alphabet: session.knownCount
        case .vocabulary: wordSession.knownCount
        }
    }

    var reviewLaterCount: Int {
        switch mode {
        case .alphabet: session.reviewLaterCount
        case .vocabulary: wordSession.reviewLaterCount
        }
    }
}
