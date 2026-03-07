import Foundation

/// Word/vocabulary model (maps to words table).
struct Word: Identifiable, Codable {
    let id: String
    let fidel: String
    let transliteration: String
    let translation: String
    let audioUrl: String?
    let lessonId: String
    let order: Int
    let exampleSentence: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case fidel
        case transliteration
        case translation
        case audioUrl = "audio_url"
        case lessonId = "lesson_id"
        case order
        case exampleSentence = "example_sentence"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
