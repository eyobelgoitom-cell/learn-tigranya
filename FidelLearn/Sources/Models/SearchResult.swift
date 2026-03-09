import Foundation

/// A search result from lessons, words, or Fidel characters.
struct SearchResult: Identifiable {
    let id: String
    let type: SearchResultType
    let title: String
    let subtitle: String?
    let lessonId: String?
    let lesson: Lesson?

    enum SearchResultType: String {
        case lesson
        case word
        case fidelCharacter
    }
}
