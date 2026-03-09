import Foundation

/// A learning event for analytics and insights.
struct LearningEvent: Sendable {
    let eventType: LearningEventType
    let payload: [String: String]

    enum LearningEventType: String, Sendable {
        case quizAnswer = "quiz_answer"
        case flashcardReview = "flashcard_review"
        case lessonView = "lesson_view"
        case lessonComplete = "lesson_complete"
        case audioPlay = "audio_play"
    }

    func toJSON() -> [String: Any] {
        var dict: [String: Any] = ["event_type": eventType.rawValue]
        for (k, v) in payload {
            dict["payload_\(k)"] = v
        }
        return dict
    }

    /// Encodes payload for storage. Uses flat structure for JSONB compatibility.
    func encodedPayload() -> [String: String] {
        var result = ["event_type": eventType.rawValue]
        result.merge(payload) { _, new in new }
        return result
    }
}
