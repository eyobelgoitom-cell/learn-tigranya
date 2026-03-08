import Foundation

@MainActor
final class VocabularyLessonViewModel: ObservableObject {
    @Published var words: [Word] = []
    @Published var isLoading = false

    private let lessonId: String
    private let lessonService: LessonServiceProtocol

    init(lessonId: String, lessonService: LessonServiceProtocol) {
        self.lessonId = lessonId
        self.lessonService = lessonService
    }

    func loadWords() {
        isLoading = true
        Task {
            words = await lessonService.getWords(lessonId: lessonId)
            isLoading = false
        }
    }
}
