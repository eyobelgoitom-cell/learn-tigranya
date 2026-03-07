import Foundation

/// Flashcard model (maps to flashcards table).
struct Flashcard: Identifiable, Codable {
    let id: String
    let wordId: String
    let userId: String
    let nextReviewAt: Date?
    let repetitionCount: Int
    let easeFactor: Double
    let interval: Int
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case wordId = "word_id"
        case userId = "user_id"
        case nextReviewAt = "next_review_at"
        case repetitionCount = "repetition_count"
        case easeFactor = "ease_factor"
        case interval
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
