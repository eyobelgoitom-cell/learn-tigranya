import SwiftUI

struct QuizPracticeView: View {
    let progressService: SyncProgressService
    let learningEventService: SyncLearningEventService
    let initialMode: PracticeIntent?
    @StateObject private var viewModel: QuizPracticeViewModel

    init(progressService: SyncProgressService, learningEventService: SyncLearningEventService, initialMode: PracticeIntent? = nil) {
        self.progressService = progressService
        self.learningEventService = learningEventService
        self.initialMode = initialMode
        _viewModel = StateObject(wrappedValue: QuizPracticeViewModel(
            progressService: progressService,
            learningEventService: learningEventService,
            insightsService: LocalInsightsService()
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading quiz…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isComplete {
                completionView
            } else if viewModel.mode == .alphabet, let question = viewModel.session.currentQuestion {
                questionView(question: question)
            } else if viewModel.mode == .vocabulary, let question = viewModel.wordSession.currentQuestion {
                wordQuestionView(question: question)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Mode", selection: $viewModel.mode) {
                    ForEach(QuizMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
                .onChange(of: viewModel.mode) { _ in viewModel.loadQuiz() }
            }
        }
        .onAppear { viewModel.loadQuiz(initialMode: initialMode) }
    }

    private func questionView(question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                progressIndicator
                questionCard(question: question)
                if !viewModel.session.showFeedback {
                    answerButtons(question: question)
                } else {
                    feedbackSection(question: question)
                }
            }
            .padding(24)
        }
    }

    private func wordQuestionView(question: WordQuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                progressIndicator
                wordQuestionCard(question: question)
                if !viewModel.wordSession.showFeedback {
                    wordAnswerButtons(question: question)
                } else {
                    wordFeedbackSection(question: question)
                }
            }
            .padding(24)
        }
    }

    private var progressIndicator: some View {
        HStack {
            Text("\(viewModel.progress.current) / \(viewModel.progress.total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func questionCard(question: QuizQuestion) -> some View {
        VStack(spacing: 16) {
            Text("What sound is this?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(question.character.character)
                .font(.system(size: 80, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func wordQuestionCard(question: WordQuizQuestion) -> some View {
        VStack(spacing: 16) {
            Text("What does this mean?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(question.word.fidel)
                .font(.system(size: 56, weight: .medium))
            Text(question.word.transliteration)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func answerButtons(question: QuizQuestion) -> some View {
        VStack(spacing: FidelTheme.spaceM) {
            ForEach(question.options, id: \.self) { option in
                Button {
                    viewModel.submitAnswer(option)
                } label: {
                    Text(option)
                        .font(FidelTheme.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FidelTheme.spaceM)
                        .minTouchTarget()
                }
                .buttonStyle(.bordered)
                .tint(.primary)
                .accessibilityLabel("Answer: \(option)")
                .accessibilityHint("Select this as your answer")
            }
        }
    }

    private func wordAnswerButtons(question: WordQuizQuestion) -> some View {
        VStack(spacing: FidelTheme.spaceM) {
            ForEach(question.options, id: \.self) { option in
                Button {
                    viewModel.submitAnswer(option)
                } label: {
                    Text(option)
                        .font(FidelTheme.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FidelTheme.spaceM)
                        .minTouchTarget()
                }
                .buttonStyle(.bordered)
                .tint(.primary)
                .accessibilityLabel("Answer: \(option)")
                .accessibilityHint("Select this as your answer")
            }
        }
    }

    private func feedbackSection(question: QuizQuestion) -> some View {
        VStack(spacing: 20) {
            if viewModel.session.selectedAnswer == question.correctAnswer {
                Label("Correct!", systemImage: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            } else {
                VStack(spacing: 8) {
                    Label("Incorrect", systemImage: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    Text("Answer: \(question.correctAnswer)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                viewModel.session.next()
            } label: {
                Text("Next")
                    .font(FidelTheme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FidelTheme.spaceM)
                    .minTouchTarget()
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .accessibilityLabel("Next question")
            .accessibilityHint("Continue to the next quiz question")
        }
    }

    private func wordFeedbackSection(question: WordQuizQuestion) -> some View {
        VStack(spacing: 20) {
            if viewModel.wordSession.selectedAnswer == question.correctAnswer {
                Label("Correct!", systemImage: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            } else {
                VStack(spacing: 8) {
                    Label("Incorrect", systemImage: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    Text("Answer: \(question.correctAnswer)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                viewModel.wordSession.next()
            } label: {
                Text("Next")
                    .font(FidelTheme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FidelTheme.spaceM)
                    .minTouchTarget()
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .accessibilityLabel("Next question")
            .accessibilityHint("Continue to the next quiz question")
        }
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
            Text("Quiz Complete!")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Score: \(viewModel.score) / \(viewModel.totalQuestions)")
                .font(.title3)
            Button("Try Again") {
                viewModel.loadQuiz()
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
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Questions")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Complete lessons to unlock quizzes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        QuizPracticeView(
            progressService: SyncProgressService(getIsAuthenticated: { false }),
            learningEventService: SyncLearningEventService(getIsAuthenticated: { false })
        )
    }
}
