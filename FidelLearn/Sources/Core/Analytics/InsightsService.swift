import Foundation

/// Provides learning insights: weak characters, weak words, mastery by group.
protocol InsightsServiceProtocol: Sendable {
    func getWeakCharacters(limit: Int) async -> [FidelCharacter]
    func getWeakWords(limit: Int) async -> [Word]
    func getMasteryByConsonantGroup() async -> [(group: String, accuracy: Double)]
}

/// Local insights from learning events. No network required.
final class LocalInsightsService: InsightsServiceProtocol, @unchecked Sendable {
    private let eventService: LocalLearningEventService
    private let lessonService: LessonServiceProtocol

    init(
        eventService: LocalLearningEventService = LocalLearningEventService(),
        lessonService: LessonServiceProtocol = LocalLessonService()
    ) {
        self.eventService = eventService
        self.lessonService = lessonService
    }

    func getWeakCharacters(limit: Int) async -> [FidelCharacter] {
        let events = await eventService.getRecentEvents(eventType: .quizAnswer, limit: 500)
        let quizEvents = events.filter { $0.payload["question_type"] == "alphabet" }
        var wrongCount: [String: Int] = [:]
        var totalCount: [String: Int] = [:]
        for event in quizEvents {
            guard let itemId = event.payload["item_id"] else { continue }
            totalCount[itemId, default: 0] += 1
            if event.payload["correct"] == "false" {
                wrongCount[itemId, default: 0] += 1
            }
        }
        let weakIds = wrongCount
            .filter { totalCount[$0.key, default: 1] >= 2 }
            .sorted { ($0.value * 100) / totalCount[$0.key, default: 1] > ($1.value * 100) / totalCount[$1.key, default: 1] }
            .prefix(limit)
            .map(\.key)
        var characters: [FidelCharacter] = []
        let lessons = await lessonService.getLessons(language: "tigrinya")
        for lesson in lessons where lesson.type == .alphabet {
            let chars = await lessonService.getFidelCharacters(lessonId: lesson.id)
            for char in chars where weakIds.contains(char.id) {
                characters.append(char)
            }
        }
        return Array(characters.prefix(limit))
    }

    func getWeakWords(limit: Int) async -> [Word] {
        let events = await eventService.getRecentEvents(eventType: .quizAnswer, limit: 500)
        let quizEvents = events.filter { $0.payload["question_type"] == "vocabulary" }
        var wrongCount: [String: Int] = [:]
        var totalCount: [String: Int] = [:]
        for event in quizEvents {
            guard let itemId = event.payload["item_id"] else { continue }
            totalCount[itemId, default: 0] += 1
            if event.payload["correct"] == "false" {
                wrongCount[itemId, default: 0] += 1
            }
        }
        let flashcardEvents = await eventService.getRecentEvents(eventType: .flashcardReview, limit: 300)
        let reviewLaterEvents = flashcardEvents.filter { $0.payload["knew_it"] == "false" && $0.payload["item_type"] == "word" }
        for event in reviewLaterEvents {
            guard let itemId = event.payload["item_id"] else { continue }
            wrongCount[itemId, default: 0] += 1
            totalCount[itemId, default: 0] += 1
        }
        let weakIds = wrongCount
            .filter { totalCount[$0.key, default: 1] >= 1 }
            .sorted { ($0.value * 100) / max(1, totalCount[$0.key, default: 1]) > ($1.value * 100) / max(1, totalCount[$1.key, default: 1]) }
            .prefix(limit)
            .map(\.key)
        var words: [Word] = []
        let lessons = await lessonService.getLessons(language: "tigrinya")
        for lesson in lessons where lesson.type == .vocabulary {
            let w = await lessonService.getWords(lessonId: lesson.id)
            for word in w where weakIds.contains(word.id) {
                words.append(word)
            }
        }
        return Array(words.prefix(limit))
    }

    func getMasteryByConsonantGroup() async -> [(group: String, accuracy: Double)] {
        let events = await eventService.getRecentEvents(eventType: .quizAnswer, limit: 500)
        let quizEvents = events.filter { $0.payload["question_type"] == "alphabet" }
        var correctByGroup: [String: Int] = [:]
        var totalByGroup: [String: Int] = [:]
        for event in quizEvents {
            guard let group = event.payload["consonant_group"], !group.isEmpty else { continue }
            totalByGroup[group, default: 0] += 1
            if event.payload["correct"] == "true" {
                correctByGroup[group, default: 0] += 1
            }
        }
        return totalByGroup
            .map { (group: $0.key, accuracy: totalByGroup[$0.key, default: 0] > 0 ? Double(correctByGroup[$0.key, default: 0]) / Double(totalByGroup[$0.key, default: 1]) : 0) }
            .sorted { $0.group < $1.group }
    }
}
