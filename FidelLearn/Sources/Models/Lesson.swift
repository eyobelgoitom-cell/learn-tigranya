import Foundation

/// Lesson model (maps to lessons table).
struct Lesson: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let type: LessonType
    let order: Int
    let sectionId: String?
    let language: String
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case type
        case order
        case sectionId = "section_id"
        case language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum LessonType: String, Codable, Hashable {
    case alphabet
    case vocabulary
    case phrase
    case listening
}

/// Lesson section for grouping (e.g., Alphabet, Words, Phrases).
struct LessonSection: Identifiable {
    let id: String
    let title: String
    let lessons: [Lesson]
}
