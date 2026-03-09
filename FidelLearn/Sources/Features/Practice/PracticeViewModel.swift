import Foundation

@MainActor
final class PracticeViewModel: ObservableObject {
    @Published var streak = 0
    @Published var accuracy: Double = 0
    @Published var wordsLearned = 0

    private let progressService: ProgressServiceProtocol?

    init(progressService: ProgressServiceProtocol? = nil) {
        self.progressService = progressService
        loadStats()
    }

    func loadStats() {
        guard let progressService else { return }
        Task {
            streak = await progressService.getStreak()
            accuracy = await progressService.getAccuracy()
            wordsLearned = await progressService.getWordsLearned()
        }
    }

    var motivationalLine: String {
        if accuracy >= 0.8 && streak >= 3 {
            return "You're on fire! Keep it up."
        }
        if streak >= 7 {
            return "\(streak)-day streak — practice strengthens memory."
        }
        if wordsLearned >= 50 {
            return "\(wordsLearned) words learned. Review to retain."
        }
        return "Practice makes perfect. Choose a mode below."
    }
}
