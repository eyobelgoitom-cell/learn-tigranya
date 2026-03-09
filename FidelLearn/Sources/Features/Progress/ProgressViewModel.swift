import Foundation
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var wordsLearned = 0
    @Published var lessonsCompleted = 0
    @Published var streak = 0
    @Published var accuracy: Double = 0
    @Published var achievements: [Achievement] = []
    @Published var masteryByGroup: [(group: String, accuracy: Double)] = []

    private let progressService: ProgressServiceProtocol
    private let insightsService: InsightsServiceProtocol

    init(progressService: ProgressServiceProtocol, insightsService: InsightsServiceProtocol = LocalInsightsService()) {
        self.progressService = progressService
        self.insightsService = insightsService
        loadProgress()
    }

    func loadProgress() {
        Task {
            wordsLearned = await progressService.getWordsLearned()
            lessonsCompleted = await progressService.getLessonsCompleted()
            streak = await progressService.getStreak()
            accuracy = await progressService.getAccuracy()
            achievements = await progressService.getAchievements()
            masteryByGroup = await insightsService.getMasteryByConsonantGroup()
        }
    }
}
