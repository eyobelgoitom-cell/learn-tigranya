import Foundation

/// Intent to open a specific practice mode (e.g. from Home recommendations).
enum PracticeIntent: String, Identifiable {
    case weakLetters = "weak_letters"
    case weakWords = "weak_words"

    var id: String { rawValue }
}
