import Foundation
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var wordsLearned = 0
    @Published var lessonsCompleted = 0
    @Published var streak = 0
    @Published var accuracy: Double = 0
    @Published var achievements: [Achievement] = []

    private let progressService: ProgressServiceProtocol

    init(progressService: ProgressServiceProtocol = LocalProgressService()) {
        self.progressService = progressService
        loadProgress()
    }

    func loadProgress() {
        Task {
            wordsLearned = await progressService.getWordsLearned()
            lessonsCompleted = await progressService.getLessonsCompleted()
            streak = await progressService.getStreak()
            accuracy = await progressService.getAccuracy()
            achievements = await progressService.getAchievements()
        }
    }
}
