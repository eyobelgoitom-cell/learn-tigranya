import Foundation

/// Ge'ez Fidel character for alphabet lessons.
struct FidelCharacter: Identifiable, Codable {
    let id: String
    let character: String
    let transliteration: String
    let vowelOrder: Int
    let consonantGroup: String
    let audioUrl: String?
    let exampleWord: String?
    let exampleWordTranslation: String?

    enum CodingKeys: String, CodingKey {
        case id
        case character
        case transliteration
        case vowelOrder = "vowel_order"
        case consonantGroup = "consonant_group"
        case audioUrl = "audio_url"
        case exampleWord = "example_word"
        case exampleWordTranslation = "example_word_translation"
    }
}
