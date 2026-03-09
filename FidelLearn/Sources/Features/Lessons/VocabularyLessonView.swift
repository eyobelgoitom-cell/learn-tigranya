import SwiftUI

/// Full-screen vocabulary lesson with words (Fidel, transliteration, translation) and audio.
struct VocabularyLessonView: View {
    let lesson: Lesson
    @StateObject private var viewModel: VocabularyLessonViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.progressService) private var progressService

    init(
        lesson: Lesson,
        lessonService: LessonServiceProtocol = LocalLessonService()
    ) {
        self.lesson = lesson
        _viewModel = StateObject(wrappedValue: VocabularyLessonViewModel(
            lessonId: lesson.id,
            lessonService: lessonService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: FidelTheme.spaceL) {
                headerSection
                wordsList
                finishButton
            }
            .padding(FidelTheme.spaceL)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadWords() }
    }

    private var headerSection: some View {
        VStack(spacing: FidelTheme.spaceS) {
            Text(lesson.subtitle ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, FidelTheme.spaceS)
    }

    private var wordsList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(height: 200)
            } else {
                LazyVStack(spacing: FidelTheme.spaceM) {
                    ForEach(viewModel.words) { word in
                        VocabularyWordCell(word: word)
                    }
                }
            }
        }
    }

    private var finishButton: some View {
        Button {
            Task {
                await progressService.saveProgress(lessonId: lesson.id, completed: true, score: nil)
                dismiss()
            }
        } label: {
            Text("Finish Lesson")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(FidelTheme.accent)
        .padding(.top, FidelTheme.spaceL)
    }
}

// MARK: - Word Cell

private struct VocabularyWordCell: View {
    let word: Word

    var body: some View {
        HStack(spacing: FidelTheme.spaceM) {
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text(word.fidel)
                    .font(FidelTheme.fidelFontCard)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(word.transliteration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(word.translation)
                .font(.headline)
                .foregroundStyle(.primary)

            Button {
                Task { @MainActor in
                    if let audioUrl = word.audioUrl, let url = URL(string: audioUrl) {
                        await AudioService.shared.play(url: url)
                    } else {
                        await AudioService.shared.play(text: word.transliteration)
                    }
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(FidelTheme.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Play pronunciation for \(word.translation)")
            .accessibilityHint("Plays the Tigrinya word \(word.transliteration)")
        }
        .padding(FidelTheme.spaceM)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
        .shadow(color: FidelTheme.cardShadow, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        VocabularyLessonView(
            lesson: Lesson(
                id: "lesson-voc-1",
                title: "Greetings & Basics",
                subtitle: "Hello, yes, no, pronouns, and question words",
                type: .vocabulary,
                order: 22,
                sectionId: "vocabulary",
                language: "tigrinya",
                createdAt: nil,
                updatedAt: nil
            )
        )
    }
}
