import XCTest
@testable import FidelLearn

final class FidelLearnTests: XCTestCase {
    func testExample() throws {
        XCTAssertTrue(true)
    }

    func testLocalLessonService_loadsLessons() async throws {
        let service = LocalLessonService(bundle: Bundle(for: Self.self))
        let sections = await service.getLessonSections()
        XCTAssertFalse(sections.isEmpty)
        XCTAssertEqual(sections.first?.title, "Alphabet")
        let lessons = sections.flatMap { $0.lessons }
        XCTAssertGreaterThanOrEqual(lessons.count, 22)
    }

    func testLocalLessonService_loadsFidelCharacters() async throws {
        let service = LocalLessonService(bundle: Bundle(for: Self.self))
        let characters = await service.getFidelCharacters(lessonId: "lesson-1")
        XCTAssertEqual(characters.count, 7)
        XCTAssertEqual(characters.first?.character, "ሀ")
        XCTAssertEqual(characters.first?.transliteration, "ha")
    }

    @MainActor
    func testQuizSession_loadsQuestionsAndScores() async throws {
        let service = LocalLessonService(bundle: Bundle(for: Self.self))
        var allCharacters: [FidelCharacter] = []
        let lessons = await service.getLessons(language: "tigrinya")
        for lesson in lessons where lesson.type == .alphabet {
            let chars = await service.getFidelCharacters(lessonId: lesson.id)
            allCharacters.append(contentsOf: chars)
        }
        let session = QuizSession()
        session.loadQuestions(from: allCharacters, count: 5)
        XCTAssertEqual(session.questions.count, 5)
        XCTAssertEqual(session.score, 0)
        guard let question = session.currentQuestion else { return }
        session.selectAnswer(question.correctAnswer)
        XCTAssertEqual(session.score, 1)
    }

    func testLocalProgressService_recordQuizAttempt() async throws {
        let suiteName = "test_fidel_learn_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let service = LocalProgressService(defaults: defaults)

        await service.recordQuizAttempt(correct: true)
        await service.recordQuizAttempt(correct: false)
        await service.recordQuizAttempt(correct: true)

        let accuracy = await service.getAccuracy()
        XCTAssertEqual(accuracy, 2.0 / 3.0, accuracy: 0.001)
    }

    func testLocalLessonService_loadsVocabularyWords() async throws {
        let service = LocalLessonService(bundle: Bundle(for: Self.self))
        let words = await service.getWords(lessonId: "lesson-voc-1")
        XCTAssertFalse(words.isEmpty)
        XCTAssertEqual(words.first?.fidel, "ሰላም")
        XCTAssertEqual(words.first?.translation, "hello")
    }

    func testLocalLessonService_loadsVocabularyLessons() async throws {
        let service = LocalLessonService(bundle: Bundle(for: Self.self))
        let sections = await service.getLessonSections()
        let vocabularySection = sections.first { $0.id == "vocabulary" }
        XCTAssertNotNil(vocabularySection)
        XCTAssertGreaterThanOrEqual(vocabularySection?.lessons.count ?? 0, 10)
    }

    @MainActor
    func testWordQuizSession_loadsQuestionsAndScores() async throws {
        let service = LocalLessonService(bundle: Bundle(for: Self.self))
        var allWords: [Word] = []
        let lessons = await service.getLessons(language: "tigrinya")
        for lesson in lessons where lesson.type == .vocabulary {
            let words = await service.getWords(lessonId: lesson.id)
            allWords.append(contentsOf: words)
        }
        let session = WordQuizSession()
        session.loadQuestions(from: allWords, count: 5)
        XCTAssertEqual(session.questions.count, 5)
        XCTAssertEqual(session.score, 0)
        guard let question = session.currentQuestion else { return }
        session.selectAnswer(question.correctAnswer)
        XCTAssertEqual(session.score, 1)
    }

    func testLocalProgressService_getWordsLearned() async throws {
        let suiteName = "test_words_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let lessonService = LocalLessonService(bundle: Bundle(for: Self.self))
        let progressService = LocalProgressService(defaults: defaults, lessonService: lessonService)

        var wordsLearned = await progressService.getWordsLearned()
        XCTAssertEqual(wordsLearned, 0)

        await progressService.saveProgress(lessonId: "lesson-voc-1", completed: true, score: nil)
        let wordsInLesson1 = await lessonService.getWords(lessonId: "lesson-voc-1")
        wordsLearned = await progressService.getWordsLearned()
        XCTAssertEqual(wordsLearned, wordsInLesson1.count)
    }
}
