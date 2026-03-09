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

                Section("Practice Modes") {
                    NavigationLink {
                        FlashcardPracticeView(learningEventService: learningEventService)
                    } label: {
                        PracticeModeRow(
                            title: "Flashcards",
                            icon: "rectangle.stack.fill",
                            subtitle: "Flip cards to learn letters and words"
                        )
                    }
                    NavigationLink {
                        QuizPracticeView(progressService: progressService, learningEventService: learningEventService)
                    } label: {
                        PracticeModeRow(
                            title: "Quizzes",
                            icon: "questionmark.circle.fill",
                            subtitle: "Test your knowledge with multiple choice"
                        )
                    }
                    NavigationLink {
                        PronunciationPracticeView()
                    } label: {
                        PracticeModeRow(
                            title: "Pronunciation",
                            icon: "mic.fill",
                            subtitle: "Listen and repeat aloud"
                        )
                    }
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
        HStack(alignment: .top, spacing: FidelTheme.spaceM) {
            Text("ሀ")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(FidelTheme.accent)
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
        VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
            Label(title, systemImage: icon)
            Text(subtitle)
                .font(FidelTheme.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PracticeView(progressService: SyncProgressService(getIsAuthenticated: { false }), practiceIntent: .constant(nil))
}
