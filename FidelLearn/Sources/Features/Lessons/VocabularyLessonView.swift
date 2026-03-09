import SwiftUI

/// Full-screen vocabulary lesson with words (Fidel, transliteration, translation) and audio.
struct VocabularyLessonView: View {
    let lesson: Lesson
    @StateObject private var viewModel: VocabularyLessonViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.progressService) private var progressService
    @Environment(\.learningEventService) private var learningEventService
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadWords()
            if reduceMotion { appeared = true }
            else { withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true } }
            Task {
                await learningEventService.record(LearningEvent(
                    eventType: .lessonView,
                    payload: ["lesson_id": lesson.id, "lesson_type": "vocabulary"]
                ))
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: FidelTheme.spaceS) {
            if !viewModel.words.isEmpty {
                HStack(spacing: FidelTheme.spaceM) {
                    Text("\(viewModel.words.count) words")
                        .font(FidelTheme.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text("Tap play to hear each word")
                        .font(FidelTheme.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Text(lesson.subtitle ?? "")
                .font(FidelTheme.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(FidelTheme.spaceM)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .fill(FidelTheme.cardBackground)
        )
        .padding(.bottom, FidelTheme.spaceS)
    }

    private var wordsList: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: FidelTheme.spaceM) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading words…")
                        .font(FidelTheme.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 180)
            } else {
                LazyVStack(spacing: FidelTheme.spaceM) {
                    ForEach(viewModel.words) { word in
                        VocabularyWordCell(word: word)
                            .id(word.id)
                    }
                }
            }
        }
    }

    private var finishButton: some View {
        Button {
            HapticService.success()
            Task {
                await progressService.saveProgress(lessonId: lesson.id, completed: true, score: nil)
                await learningEventService.record(LearningEvent(
                    eventType: .lessonComplete,
                    payload: ["lesson_id": lesson.id, "lesson_type": "vocabulary"]
                ))
                dismiss()
            }
        } label: {
            Label("Finish Lesson", systemImage: "checkmark.circle.fill")
                .font(FidelTheme.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FidelTheme.spaceM)
                .minTouchTarget()
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
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ScaledButtonStyle())
            .accessibilityLabel("Play pronunciation for \(word.translation)")
            .accessibilityHint("Plays the Tigrinya word \(word.transliteration)")
        }
        .padding(FidelTheme.spaceM)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .stroke(FidelTheme.accent.opacity(0.15), lineWidth: 1)
        )
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
