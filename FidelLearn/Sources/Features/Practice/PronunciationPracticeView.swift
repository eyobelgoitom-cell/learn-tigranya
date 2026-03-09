import SwiftUI

/// Listen & repeat — browse vocabulary words and hear pronunciation.
struct PronunciationPracticeView: View {
    @StateObject private var viewModel = PronunciationPracticeViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading words…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.words.isEmpty {
                emptyState
            } else {
                wordList
            }
        }
        .navigationTitle("Pronunciation")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear { viewModel.loadWords() }
    }

    private var emptyState: some View {
        VStack(spacing: FidelTheme.spaceL) {
            ZStack {
                RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                    .fill(FidelTheme.accent.opacity(0.1))
                    .square(80)
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(FidelTheme.accent)
            }
            Text("No Words Yet")
                .font(FidelTheme.title)
            Text("Complete vocabulary lessons to practice pronunciation.")
                .font(FidelTheme.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var wordList: some View {
        ScrollView {
            LazyVStack(spacing: FidelTheme.spaceM) {
                ForEach(viewModel.words) { word in
                    PronunciationWordRow(word: word)
                        .id(word.id)
                }
            }
            .padding(FidelTheme.spaceL)
        }
    }
}

// MARK: - Word Row

private struct PronunciationWordRow: View {
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
                    .font(.title)
                    .foregroundStyle(FidelTheme.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Play \(word.translation)")
            .accessibilityHint("Listen to the Tigrinya pronunciation")
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
        PronunciationPracticeView()
    }
}
