import Foundation

@MainActor
final class PronunciationPracticeViewModel: ObservableObject {
    @Published var words: [Word] = []
    @Published var isLoading = false

    private let lessonService: LessonServiceProtocol

    init(lessonService: LessonServiceProtocol = LocalLessonService()) {
        self.lessonService = lessonService
    }

    func loadWords() {
        isLoading = true
        Task {
            let lessons = await lessonService.getLessons(language: "tigrinya")
            let vocabLessons = lessons.filter { $0.type == .vocabulary }
            var allWords: [Word] = []
            for lesson in vocabLessons {
                let lessonWords = await lessonService.getWords(lessonId: lesson.id)
                allWords.append(contentsOf: lessonWords)
            }
            words = allWords.sorted { $0.order < $1.order }
            isLoading = false
        }
    }
}
