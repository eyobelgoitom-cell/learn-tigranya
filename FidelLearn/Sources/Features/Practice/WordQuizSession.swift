import Foundation

/// A single multiple-choice vocabulary quiz question (word → translation).
struct WordQuizQuestion {
    let word: Word
    let options: [String]
    let correctAnswer: String
}

/// Manages vocabulary quiz state — questions, scoring, feedback.
@MainActor
final class WordQuizSession: ObservableObject {
    @Published var questions: [WordQuizQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isComplete = false

    var currentQuestion: WordQuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: (current: Int, total: Int) {
        (currentIndex + 1, questions.count)
    }

    func loadQuestions(from words: [Word], count: Int = 10) {
        let shuffled = words.shuffled()
        let selected = Array(shuffled.prefix(min(count, shuffled.count)))
        questions = selected.map { makeQuestion(for: $0, from: words) }
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

    private func makeQuestion(for word: Word, from pool: [Word]) -> WordQuizQuestion {
        let wrongOptions = pool
            .filter { $0.id != word.id && $0.translation != word.translation }
            .map(\.translation)
            .uniqued()
            .shuffled()
            .prefix(3)
        var options = [word.translation] + wrongOptions
        options.shuffle()
        return WordQuizQuestion(
            word: word,
            options: Array(options),
            correctAnswer: word.translation
        )
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
