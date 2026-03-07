import Foundation

/// Offline-first lesson service using bundled JSON. No network required.
final class LocalLessonService: LessonServiceProtocol, @unchecked Sendable {
    private let bundle: Bundle
    private var lessonsCache: [Lesson]?
    private var fidelCache: [FidelCharacterRecord]?
    private var wordsCache: [Word]?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func getLessonSections() async -> [LessonSection] {
        let lessons = await loadLessons()
        let sections = Dictionary(grouping: lessons) { $0.sectionId ?? "default" }
        return sections.map { key, sectionLessons in
            LessonSection(
                id: key,
                title: sectionLessons.first?.type.rawValue.capitalized ?? "Lessons",
                lessons: sectionLessons.sorted { $0.order < $1.order }
            )
        }.sorted { $0.lessons.first?.order ?? 0 < $1.lessons.first?.order ?? 0 }
    }

    func getLessons(language: String) async -> [Lesson] {
        let lessons = await loadLessons()
        return lessons.filter { $0.language == language }
    }

    func getLesson(id: String) async -> Lesson? {
        let lessons = await loadLessons()
        return lessons.first { $0.id == id }
    }

    func getNextLesson() async -> Lesson? {
        let lessons = await getLessons(language: "tigrinya")
        return lessons.first
    }

    func getWords(lessonId: String) async -> [Word] {
        let words = await loadWords()
        return words.filter { $0.lessonId == lessonId }.sorted { $0.order < $1.order }
    }

    func getFidelCharacters(lessonId: String) async -> [FidelCharacter] {
        let records = await loadFidelCharacters()
        return records
            .filter { $0.lessonId == lessonId }
            .sorted { $0.vowelOrder < $1.vowelOrder }
            .map { $0.toFidelCharacter() }
    }

    // MARK: - Private

    private func loadLessons() async -> [Lesson] {
        if let cached = lessonsCache { return cached }
        guard let url = bundle.url(forResource: "lessons", withExtension: "json", subdirectory: "Data"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Lesson].self, from: data) else {
            return []
        }
        lessonsCache = decoded
        return decoded
    }

    private func loadFidelCharacters() async -> [FidelCharacterRecord] {
        if let cached = fidelCache { return cached }
        guard let url = bundle.url(forResource: "fidel_characters", withExtension: "json", subdirectory: "Data"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([FidelCharacterRecord].self, from: data) else {
            return []
        }
        fidelCache = decoded
        return decoded
    }

    private func loadWords() async -> [Word] {
        if let cached = wordsCache { return cached }
        guard let url = bundle.url(forResource: "words", withExtension: "json", subdirectory: "Data"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Word].self, from: data) else {
            return []
        }
        wordsCache = decoded
        return decoded
    }
}

// MARK: - JSON Decoding

private struct FidelCharacterRecord: Codable {
    let id: String
    let character: String
    let transliteration: String
    let vowelOrder: Int
    let consonantGroup: String
    let lessonId: String

    enum CodingKeys: String, CodingKey {
        case id
        case character
        case transliteration
        case vowelOrder = "vowel_order"
        case consonantGroup = "consonant_group"
        case lessonId = "lesson_id"
    }

    func toFidelCharacter() -> FidelCharacter {
        FidelCharacter(
            id: id,
            character: character,
            transliteration: transliteration,
            vowelOrder: vowelOrder,
            consonantGroup: consonantGroup,
            audioUrl: nil,
            exampleWord: nil,
            exampleWordTranslation: nil
        )
    }
}
