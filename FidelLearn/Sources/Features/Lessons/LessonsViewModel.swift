import Foundation
import Combine

@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var lessonSections: [LessonSection] = []
    @Published var selectedLesson: Lesson?
    @Published var isLoading = false
    @Published var lessonProgress: [String: LessonProgress] = [:]
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false

    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol
    private var searchTask: Task<Void, Never>?

    init(
        lessonService: LessonServiceProtocol = LocalLessonService(),
        progressService: ProgressServiceProtocol
    ) {
        self.lessonService = lessonService
        self.progressService = progressService
        loadLessons()
    }

    func performSearch() {
        searchTask?.cancel()
        let q = searchText.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            searchResults = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            isSearching = true
            searchResults = await lessonService.search(query: q, language: "tigrinya")
            isSearching = false
        }
    }

    func loadLessons() {
        isLoading = true
        Task {
            lessonSections = await lessonService.getLessonSections()
            await loadProgressForLessons()
            isLoading = false
        }
    }

    func refreshProgress() {
        Task {
            await loadProgressForLessons()
        }
    }

    func progress(for lessonId: String) -> LessonProgress? {
        lessonProgress[lessonId]
    }

    func selectLesson(_ lesson: Lesson) {
        selectedLesson = lesson
    }

    private func loadProgressForLessons() async {
        var progress: [String: LessonProgress] = [:]
        for section in lessonSections {
            for lesson in section.lessons {
                if let p = await progressService.getLessonProgress(lessonId: lesson.id) {
                    progress[lesson.id] = p
                }
            }
        }
        lessonProgress = progress
    }
}
