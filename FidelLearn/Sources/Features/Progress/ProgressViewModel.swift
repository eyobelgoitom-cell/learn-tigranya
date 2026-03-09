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

    /// Motivational summary for hero section.
    var motivationalSummary: String {
        if lessonsCompleted >= 20 && wordsLearned >= 50 {
            return "Outstanding progress! You're mastering Tigrinya."
        }
        if streak >= 7 {
            return "\(streak)-day streak — consistency is key."
        }
        if accuracy >= 0.8 {
            return "\(Int(accuracy * 100))% accuracy. You're retaining well."
        }
        if wordsLearned >= 25 {
            return "\(wordsLearned) words learned. Keep building vocabulary."
        }
        if lessonsCompleted > 0 {
            return "\(lessonsCompleted) lessons completed. Every step counts."
        }
        return "Complete lessons and practice to see your stats here."
    }

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
