import SwiftUI

struct QuizPracticeView: View {
    @StateObject private var viewModel = QuizPracticeViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading quiz…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.session.isComplete {
                completionView
            } else if let question = viewModel.session.currentQuestion {
                questionView(question: question)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadQuiz() }
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

    private var progressIndicator: some View {
        HStack {
            Text("\(viewModel.session.progress.current) / \(viewModel.session.progress.total)")
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

    private func answerButtons(question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options, id: \.self) { option in
                Button {
                    viewModel.session.selectAnswer(option)
                } label: {
                    Text(option)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .tint(.primary)
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
            Button("Next") {
                viewModel.session.next()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
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
            Text("Score: \(viewModel.session.score) / \(viewModel.session.questions.count)")
                .font(.title3)
            Button("Try Again") {
                viewModel.loadQuiz()
            }
            .buttonStyle(.borderedProminent)
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
        QuizPracticeView()
    }
}
