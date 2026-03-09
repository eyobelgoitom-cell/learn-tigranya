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

    init(lessonService: LessonServiceProtocol = LocalLessonService()) {
        self.lessonService = lessonService
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
