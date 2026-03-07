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
}
