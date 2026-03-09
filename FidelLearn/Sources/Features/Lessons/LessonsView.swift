import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel: LessonsViewModel

    init(progressService: SyncProgressService) {
        _viewModel = StateObject(wrappedValue: LessonsViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading lessons…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.lessonSections.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No Lessons")
                            .font(.headline)
                        Text("Lessons will appear here once loaded.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.lessonSections) { section in
                            Section(section.title) {
                                ForEach(section.lessons) { lesson in
                                    NavigationLink(value: lesson) {
                                        LessonRowView(lesson: lesson, progress: viewModel.progress(for: lesson.id))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lessons")
            .listStyle(.insetGrouped)
            .navigationDestination(for: Lesson.self) { lesson in
                if lesson.type == .vocabulary {
                    VocabularyLessonView(lesson: lesson)
                } else {
                    AlphabetLessonView(lesson: lesson)
                }
            }
            .onAppear { viewModel.refreshProgress() }
        }
        .onAppear {
            if viewModel.lessonSections.isEmpty && !viewModel.isLoading {
                viewModel.loadLessons()
            }
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let progress: LessonProgress?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                Text(lesson.subtitle ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let progress, progress.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LessonsView(progressService: SyncProgressService(getIsAuthenticated: { false }))
}
