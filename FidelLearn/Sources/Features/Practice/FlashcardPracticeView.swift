import SwiftUI

struct FlashcardPracticeView: View {
    let learningEventService: SyncLearningEventService
    @StateObject private var viewModel: FlashcardPracticeViewModel

    init(learningEventService: SyncLearningEventService) {
        self.learningEventService = learningEventService
        _viewModel = StateObject(wrappedValue: FlashcardPracticeViewModel(learningEventService: learningEventService))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading flashcards…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isComplete {
                completionView
            } else if viewModel.mode == .alphabet, let card = viewModel.session.currentCard {
                cardView(card: card)
            } else if viewModel.mode == .vocabulary, let card = viewModel.wordSession.currentCard {
                wordCardView(card: card)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Mode", selection: $viewModel.mode) {
                    ForEach(FlashcardMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
                .onChange(of: viewModel.mode) { _ in viewModel.loadCards() }
            }
        }
        .onAppear { viewModel.loadCards() }
    }

    private func cardView(card: FidelCharacter) -> some View {
        VStack(spacing: 24) {
            progressIndicator
            FlashcardView(
                character: card,
                isFlipped: viewModel.session.isFlipped,
                onTap: { viewModel.session.flip() }
            )
            if viewModel.session.isFlipped {
                actionButtons
            } else {
                Text("Tap card to reveal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }

    private func wordCardView(card: Word) -> some View {
        VStack(spacing: 24) {
            progressIndicator
            WordFlashcardView(
                word: card,
                isFlipped: viewModel.wordSession.isFlipped,
                onTap: { viewModel.wordSession.flip() }
            )
            if viewModel.wordSession.isFlipped {
                wordActionButtons
            } else {
                Text("Tap card to reveal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }

    private var progressIndicator: some View {
        HStack {
            Text("\(viewModel.progress.current) / \(viewModel.progress.total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.recordAndReviewLater()
            } label: {
                Label("Review Later", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Review later")
            .accessibilityHint("Adds card to review queue")

            Button {
                viewModel.recordAndKnowIt()
            } label: {
                Label("Know It", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .accessibilityLabel("Know it")
            .accessibilityHint("Marks card as learned")
        }
    }

    private var wordActionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.recordAndReviewLater()
            } label: {
                Label("Review Later", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Review later")
            .accessibilityHint("Adds card to review queue")

            Button {
                viewModel.recordAndKnowIt()
            } label: {
                Label("Know It", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .accessibilityLabel("Know it")
            .accessibilityHint("Marks card as learned")
        }
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(FidelTheme.success)
            Text("Session Complete!")
                .font(.title2)
                .fontWeight(.semibold)
            Text("You knew \(viewModel.knownCount) and will review \(viewModel.reviewLaterCount) later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Practice Again") {
                viewModel.loadCards()
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Flashcards")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Complete lessons to unlock flashcards.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Flashcard View

private struct FlashcardView: View {
    let character: FidelCharacter
    let isFlipped: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                cardFace(
                    content: cardFrontContent,
                    background: Color(.secondarySystemGroupedBackground)
                )
                .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))

                cardFace(
                    content: cardBackContent,
                    background: Color(.tertiarySystemGroupedBackground)
                )
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .buttonStyle(.plain)
        .frame(height: 220)
    }

    private func cardFace<Content: View>(content: Content, background: Color) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
    }

    private var cardFrontContent: some View {
        VStack(spacing: 16) {
            Text(character.character)
                .font(.system(size: 72, weight: .medium))
            Text("Tap to reveal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var cardBackContent: some View {
        VStack(spacing: 16) {
            Text(character.character)
                .font(.system(size: 56, weight: .medium))
            Text(character.transliteration)
                .font(.title2)
                .fontWeight(.semibold)
            Button {
                Task { @MainActor in
                    await AudioService.shared.play(text: character.transliteration)
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Word Flashcard View

private struct WordFlashcardView: View {
    let word: Word
    let isFlipped: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                cardFace(
                    content: wordFrontContent,
                    background: Color(.secondarySystemGroupedBackground)
                )
                .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))

                cardFace(
                    content: wordBackContent,
                    background: Color(.tertiarySystemGroupedBackground)
                )
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .buttonStyle(.plain)
        .frame(height: 220)
        .accessibilityLabel("Vocabulary card: \(word.fidel)")
        .accessibilityHint(isFlipped ? "Shows \(word.translation)" : "Double tap to reveal translation")
    }

    private func cardFace<Content: View>(content: Content, background: Color) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
    }

    private var wordFrontContent: some View {
        VStack(spacing: 16) {
            Text(word.fidel)
                .font(.system(size: 56, weight: .medium))
            Text("Tap to reveal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var wordBackContent: some View {
        VStack(spacing: 12) {
            Text(word.fidel)
                .font(.system(size: 44, weight: .medium))
            Text(word.transliteration)
                .font(.title3)
                .fontWeight(.semibold)
            Text(word.translation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                Task { @MainActor in
                    if let urlString = word.audioUrl, let url = URL(string: urlString) {
                        await AudioService.shared.play(url: url)
                    } else {
                        await AudioService.shared.play(text: word.transliteration)
                    }
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Play pronunciation")
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardPracticeView(learningEventService: SyncLearningEventService(getIsAuthenticated: { false }))
    }
}
