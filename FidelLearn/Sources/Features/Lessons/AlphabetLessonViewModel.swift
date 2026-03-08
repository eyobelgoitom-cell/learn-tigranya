import Foundation

@MainActor
final class AlphabetLessonViewModel: ObservableObject {
    @Published var characters: [FidelCharacter] = []
    @Published var isLoading = false

    private let lessonId: String
    private let lessonService: LessonServiceProtocol

    init(lessonId: String, lessonService: LessonServiceProtocol) {
        self.lessonId = lessonId
        self.lessonService = lessonService
    }

    func loadCharacters() {
        isLoading = true
        Task {
            characters = await lessonService.getFidelCharacters(lessonId: lessonId)
            isLoading = false
        }
    }
}
