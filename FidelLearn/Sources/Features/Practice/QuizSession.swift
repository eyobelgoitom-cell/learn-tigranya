import Foundation

/// A single multiple-choice quiz question.
struct QuizQuestion {
    let character: FidelCharacter
    let options: [String]
    let correctAnswer: String
}

/// Manages quiz state — questions, scoring, feedback.
@MainActor
final class QuizSession: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isComplete = false

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: (current: Int, total: Int) {
        (currentIndex + 1, questions.count)
    }

    func loadQuestions(from characters: [FidelCharacter], count: Int = 10) {
        let shuffled = characters.shuffled()
        let selected = Array(shuffled.prefix(min(count, shuffled.count)))
        questions = selected.map { makeQuestion(for: $0, from: characters) }
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showFeedback = false
        isComplete = false
    }

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        selectedAnswer = answer
        if answer == question.correctAnswer {
            score += 1
        }
        showFeedback = true
    }

    func next() {
        selectedAnswer = nil
        showFeedback = false
        currentIndex += 1
        if currentIndex >= questions.count {
            isComplete = true
        }
    }

    private func makeQuestion(for character: FidelCharacter, from pool: [FidelCharacter]) -> QuizQuestion {
        let wrongOptions = pool
            .filter { $0.id != character.id && $0.transliteration != character.transliteration }
            .map(\.transliteration)
            .uniqued()
            .shuffled()
            .prefix(3)
        var options = [character.transliteration] + wrongOptions
        options.shuffle()
        return QuizQuestion(
            character: character,
            options: Array(options),
            correctAnswer: character.transliteration
        )
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
