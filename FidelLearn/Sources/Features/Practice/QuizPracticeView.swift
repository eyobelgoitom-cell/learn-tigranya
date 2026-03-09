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
        .background(Color(.systemGroupedBackground))
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
        VStack(spacing: FidelTheme.spaceS) {
            HStack {
                Text("\(viewModel.progress.current) of \(viewModel.progress.total)")
                    .font(FidelTheme.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(FidelTheme.accent)
                        .frame(width: viewModel.progress.total > 0 ? geo.size.width * CGFloat(viewModel.progress.current) / CGFloat(viewModel.progress.total) : 0, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func questionCard(question: QuizQuestion) -> some View {
        VStack(spacing: FidelTheme.spaceM) {
            Text("What sound is this?")
                .font(FidelTheme.caption)
                .foregroundStyle(.secondary)
            Text(question.character.character)
                .font(.system(size: 80, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(FidelTheme.spaceXL)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusXL))
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusXL)
                .stroke(FidelTheme.accent.opacity(0.2), lineWidth: 1)
        )
    }

    private func wordQuestionCard(question: WordQuizQuestion) -> some View {
        VStack(spacing: FidelTheme.spaceM) {
            Text("What does this mean?")
                .font(FidelTheme.caption)
                .foregroundStyle(.secondary)
            Text(question.word.fidel)
                .font(.system(size: 56, weight: .medium))
            Text(question.word.transliteration)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(FidelTheme.spaceXL)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusXL))
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusXL)
                .stroke(FidelTheme.accent.opacity(0.2), lineWidth: 1)
        )
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
        VStack(spacing: FidelTheme.spaceL) {
            if viewModel.session.selectedAnswer == question.correctAnswer {
                Label("Correct!", systemImage: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(FidelTheme.success)
            } else {
                VStack(spacing: 8) {
                    Label("Incorrect", systemImage: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(FidelTheme.error)
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
        VStack(spacing: FidelTheme.spaceL) {
            if viewModel.wordSession.selectedAnswer == question.correctAnswer {
                Label("Correct!", systemImage: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(FidelTheme.success)
            } else {
                VStack(spacing: 8) {
                    Label("Incorrect", systemImage: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(FidelTheme.error)
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
        VStack(spacing: FidelTheme.spaceL) {
            ZStack {
                Circle()
                    .fill(FidelTheme.accent.opacity(0.2))
                    .frame(width: 96, height: 96)
                Image(systemName: "star.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(FidelTheme.accent)
            }
            Text("Quiz Complete!")
                .font(FidelTheme.title)
            Text("Score: \(viewModel.score) / \(viewModel.totalQuestions)")
                .font(FidelTheme.headline)
                .foregroundStyle(.secondary)
            Button {
                viewModel.loadQuiz()
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(FidelTheme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FidelTheme.spaceM)
                    .minTouchTarget()
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .padding(.top, FidelTheme.spaceS)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(FidelTheme.spaceL)
    }

    private var emptyStateView: some View {
        VStack(spacing: FidelTheme.spaceL) {
            ZStack {
                RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                    .fill(FidelTheme.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(FidelTheme.accent)
            }
            Text("No Questions")
                .font(FidelTheme.title)
            Text("Complete lessons to unlock quizzes.")
                .font(FidelTheme.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(FidelTheme.spaceL)
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
