import SwiftUI

/// Full-screen alphabet lesson with large Fidel characters and transliterations.
struct AlphabetLessonView: View {
    let lesson: Lesson
    @StateObject private var viewModel: AlphabetLessonViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.progressService) private var progressService

    init(
        lesson: Lesson,
        lessonService: LessonServiceProtocol = LocalLessonService()
    ) {
        self.lesson = lesson
        _viewModel = StateObject(wrappedValue: AlphabetLessonViewModel(
            lessonId: lesson.id,
            lessonService: lessonService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                charactersGrid
                finishButton
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadCharacters() }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(lesson.subtitle ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var charactersGrid: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(height: 200)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.characters) { character in
                            FidelCharacterCell(character: character)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 140)
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

// MARK: - Character Cell

private struct FidelCharacterCell: View {
    let character: FidelCharacter

    var body: some View {
        VStack(spacing: 8) {
            Text(character.character)
                .font(FidelTheme.fidelFontCard)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(character.transliteration)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Button {
                Task { @MainActor in
                    await AudioService.shared.play(text: character.transliteration)
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(FidelTheme.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Play pronunciation")
            .accessibilityHint("Plays the sound for \(character.transliteration)")
        }
        .frame(minWidth: 64, minHeight: 100)
        .padding(.horizontal, FidelTheme.spaceL)
        .padding(.vertical, FidelTheme.spaceM)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
        .shadow(color: FidelTheme.cardShadow, radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: character.id)
    }
}

#Preview {
    NavigationStack {
        AlphabetLessonView(
            lesson: Lesson(
                id: "lesson-1",
                title: "ሀ ሁ ሂ ሃ ሄ ህ ሆ",
                subtitle: "H sound — ha, hu, hi, ha, he, hə, ho",
                type: .alphabet,
                order: 0,
                sectionId: "alphabet",
                language: "tigrinya",
                createdAt: nil,
                updatedAt: nil
            )
        )
    }
}
