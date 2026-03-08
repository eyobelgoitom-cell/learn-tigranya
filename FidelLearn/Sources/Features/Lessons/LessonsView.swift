import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()

    var body: some View {
        NavigationStack {
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
    LessonsView()
}
