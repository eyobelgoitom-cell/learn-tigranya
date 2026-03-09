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
    @Published var lessonsCompletedToday = 0
    @Published var dailyGoal = 3

    /// Streak at risk (evening, no progress today).
    var isStreakAtRisk: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return streak > 0 && lessonsCompletedToday == 0 && hour >= 18
    }

    /// Smart next step suggestion.
    var nextStepSuggestion: String? {
        if isStreakAtRisk { return "Quick lesson to save your streak?" }
        let unlocked = achievements.filter(\.isUnlocked).count
        if unlocked < achievements.count, let next = achievements.first(where: { !$0.isUnlocked }) {
            switch next.id {
            case "1": return lessonsCompleted < 1 ? "Complete 1 lesson to unlock First Steps" : nil
            case "2": return streak < 7 ? "\(7 - streak) more days for 7-Day Streak" : nil
            case "3": return wordsLearned < 100 ? "\(100 - wordsLearned) words to Century" : nil
            default: return nil
            }
        }
        if lessonsCompleted == 0 { return "Start with an alphabet lesson" }
        if accuracy < 0.5 && lessonsCompleted > 0 { return "Practice with flashcards to improve" }
        return nil
    }

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
            let (completed, goal) = await progressService.getDailyProgress()
            lessonsCompletedToday = completed
            dailyGoal = goal
        }
    }
}
