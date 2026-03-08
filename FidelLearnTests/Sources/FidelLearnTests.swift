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
}
