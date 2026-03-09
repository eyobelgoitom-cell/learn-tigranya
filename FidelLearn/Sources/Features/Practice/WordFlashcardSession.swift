import Foundation

/// Manages a vocabulary flashcard session — deck, flip, next, "Know it" / "Review later".
@MainActor
final class WordFlashcardSession: ObservableObject {
    @Published var cards: [Word] = []
    @Published var currentIndex = 0
    @Published var isFlipped = false
    @Published var isComplete = false
    @Published var knownCount = 0
    @Published var reviewLaterCount = 0

    var currentCard: Word? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var progress: (current: Int, total: Int) {
        (currentIndex + 1, cards.count)
    }

    private var reviewQueue: [Word] = []

    func loadCards(from words: [Word]) {
        cards = words.shuffled()
        currentIndex = 0
        isFlipped = false
        isComplete = false
        knownCount = 0
        reviewLaterCount = 0
        reviewQueue = []
    }

    func flip() {
        isFlipped = true
    }

    func knowIt() {
        guard currentCard != nil else { return }
        knownCount += 1
        advance()
    }

    func reviewLater() {
        guard let card = currentCard else { return }
        reviewLaterCount += 1
        reviewQueue.append(card)
        advance()
    }

    private func advance() {
        isFlipped = false
        currentIndex += 1
        if currentIndex >= cards.count {
            if reviewQueue.isEmpty {
                isComplete = true
            } else {
                cards = reviewQueue.shuffled()
                reviewQueue = []
                currentIndex = 0
            }
        }
    }
}
