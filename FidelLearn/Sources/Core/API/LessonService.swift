import Foundation

protocol LessonServiceProtocol: Sendable {
    func getLessonSections() async -> [LessonSection]
    func getLessons(language: String) async -> [Lesson]
    func getLesson(id: String) async -> Lesson?
    func getNextLesson() async -> Lesson?
    func getWords(lessonId: String) async -> [Word]
    func getFidelCharacters(lessonId: String) async -> [FidelCharacter]
}

final class LessonService: LessonServiceProtocol {
    private let client = SupabaseConfig.client

    func getLessonSections() async -> [LessonSection] {
        do {
            let lessons: [Lesson] = try await client
                .from("lessons")
                .select()
                .order("order", ascending: true)
                .execute()
                .value

            let sections = Dictionary(grouping: lessons) { $0.sectionId ?? "default" }
            return sections.map { key, lessons in
                LessonSection(
                    id: key,
                    title: lessons.first?.type.rawValue.capitalized ?? "Lessons",
                    lessons: lessons.sorted { $0.order < $1.order }
                )
            }.sorted { $0.lessons.first?.order ?? 0 < $1.lessons.first?.order ?? 0 }
        } catch {
            return fallbackLessonSections()
        }
    }

    func getLessons(language: String) async -> [Lesson] {
        do {
            let lessons: [Lesson] = try await client
                .from("lessons")
                .select()
                .eq("language", value: language)
                .order("order", ascending: true)
                .execute()
                .value
            return lessons
        } catch {
            return []
        }
    }

    func getLesson(id: String) async -> Lesson? {
        do {
            let lesson: Lesson = try await client
                .from("lessons")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            return lesson
        } catch {
            return nil
        }
    }

    func getNextLesson() async -> Lesson? {
        let lessons = await getLessons(language: "tigrinya")
        return lessons.first
    }

    func getWords(lessonId: String) async -> [Word] {
        do {
            let words: [Word] = try await client
                .from("words")
                .select()
                .eq("lesson_id", value: lessonId)
                .order("order", ascending: true)
                .execute()
                .value
            return words
        } catch {
            return []
        }
    }

    func getFidelCharacters(lessonId: String) async -> [FidelCharacter] {
        do {
            let characters: [FidelCharacter] = try await client
                .from("fidel_characters")
                .select()
                .eq("lesson_id", value: lessonId)
                .order("vowel_order", ascending: true)
                .execute()
                .value
            return characters
        } catch {
            return []
        }
    }

    private func fallbackLessonSections() -> [LessonSection] {
        [
            LessonSection(
                id: "alphabet",
                title: "Alphabet",
                lessons: [
                    Lesson(
                        id: "1",
                        title: "Fidel: ሀ ሁ ሂ ሃ ሄ ህ ሆ",
                        subtitle: "Learn the first row",
                        type: .alphabet,
                        order: 0,
                        sectionId: "alphabet",
                        language: "tigrinya",
                        createdAt: nil,
                        updatedAt: nil
                    )
                ]
            )
        ]
    }
}
