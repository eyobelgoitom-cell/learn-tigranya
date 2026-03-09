import SwiftUI

struct PracticeView: View {
    @Binding var practiceIntent: PracticeIntent?
    let progressService: SyncProgressService
    @Environment(\.learningEventService) private var learningEventService
    @StateObject private var viewModel: PracticeViewModel
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(progressService: SyncProgressService, practiceIntent: Binding<PracticeIntent?> = .constant(nil)) {
        self.progressService = progressService
        _practiceIntent = practiceIntent
        _viewModel = StateObject(wrappedValue: PracticeViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    practiceHeroRow
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

                Section {
                    NavigationLink {
                        FlashcardPracticeView(learningEventService: learningEventService)
                    } label: {
                        PracticeModeRow(
                            title: "Flashcards",
                            icon: "rectangle.stack.fill",
                            subtitle: "Flip cards to learn letters and words"
                        )
                    }
                    .listRowBackground(FidelTheme.cardBackground)
                    NavigationLink {
                        QuizPracticeView(progressService: progressService, learningEventService: learningEventService)
                    } label: {
                        PracticeModeRow(
                            title: "Quizzes",
                            icon: "questionmark.circle.fill",
                            subtitle: "Test your knowledge with multiple choice"
                        )
                    }
                    .listRowBackground(FidelTheme.cardBackground)
                    NavigationLink {
                        PronunciationPracticeView()
                    } label: {
                        PracticeModeRow(
                            title: "Pronunciation",
                            icon: "mic.fill",
                            subtitle: "Listen and repeat aloud"
                        )
                    }
                    .listRowBackground(FidelTheme.cardBackground)
                } header: {
                    Label("Practice Modes", systemImage: "brain.head.profile")
                        .font(FidelTheme.headline)
                        .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Practice")
            .listStyle(.insetGrouped)
            .refreshable { viewModel.loadStats() }
            .onAppear {
                viewModel.loadStats()
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
                }
            }
            .fullScreenCover(item: $practiceIntent) { intent in
                NavigationStack {
                    QuizPracticeView(
                        progressService: progressService,
                        learningEventService: learningEventService,
                        initialMode: intent
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                practiceIntent = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private var practiceHeroRow: some View {
        HStack(alignment: .center, spacing: FidelTheme.spaceM) {
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 4)
                    .square(56)
                if viewModel.accuracy > 0 {
                    Circle()
                        .trim(from: 0, to: viewModel.accuracy)
                        .stroke(FidelTheme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .square(56)
                        .rotationEffect(.degrees(-90))
                }
                Text("ሀ")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(FidelTheme.accent)
            }
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text("Practice")
                    .font(FidelTheme.headline)
                Text(viewModel.motivationalLine)
                    .font(FidelTheme.body)
                    .foregroundStyle(.secondary)
                if viewModel.accuracy > 0 || viewModel.streak > 0 {
                    HStack(spacing: FidelTheme.spaceM) {
                        if viewModel.accuracy > 0 {
                            Label("\(Int(viewModel.accuracy * 100))% accuracy", systemImage: "target")
                                .font(FidelTheme.caption)
                                .foregroundStyle(.tertiary)
                        }
                        if viewModel.streak > 0 {
                            Label("\(viewModel.streak) day streak", systemImage: "flame.fill")
                                .font(FidelTheme.caption)
                                .foregroundStyle(FidelTheme.streak)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FidelTheme.spaceM)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .fill(FidelTheme.cardBackground)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: appeared)
    }
}

struct PracticeModeRow: View {
    let title: String
    let icon: String
    let subtitle: String

    var body: some View {
        HStack(spacing: FidelTheme.spaceM) {
            ZStack {
                RoundedRectangle(cornerRadius: FidelTheme.radiusS)
                    .fill(FidelTheme.accent.opacity(0.15))
                    .square(40)
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(FidelTheme.accent)
            }
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text(title)
                    .font(FidelTheme.headline)
                Text(subtitle)
                    .font(FidelTheme.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, FidelTheme.spaceS)
    }
}

#Preview {
    PracticeView(progressService: SyncProgressService(getIsAuthenticated: { false }), practiceIntent: .constant(nil))
}
