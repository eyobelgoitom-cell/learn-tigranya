import Foundation

@MainActor
final class FlashcardPracticeViewModel: ObservableObject {
    @Published var session = FlashcardSession()
    @Published var isLoading = false

    private let lessonService: LessonServiceProtocol

    init(lessonService: LessonServiceProtocol = LocalLessonService()) {
        self.lessonService = lessonService
    }

    func loadCards() {
        isLoading = true
        Task {
            let lessons = await lessonService.getLessons(language: "tigrinya")
            var allCharacters: [FidelCharacter] = []
            for lesson in lessons where lesson.type == .alphabet {
                let chars = await lessonService.getFidelCharacters(lessonId: lesson.id)
                allCharacters.append(contentsOf: chars)
            }
            session.loadCards(from: allCharacters)
            isLoading = false
        }
    }
}
