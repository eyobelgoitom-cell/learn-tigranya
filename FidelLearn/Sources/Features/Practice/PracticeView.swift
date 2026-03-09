import SwiftUI

struct PracticeView: View {
    @Binding var practiceIntent: PracticeIntent?
    @Environment(\.progressService) private var progressService
    @Environment(\.learningEventService) private var learningEventService
    @StateObject private var viewModel = PracticeViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Practice Modes") {
                    NavigationLink {
                        FlashcardPracticeView(learningEventService: learningEventService)
                    } label: {
                        Label("Flashcards", systemImage: "rectangle.stack.fill")
                    }
                    NavigationLink {
                        QuizPracticeView(progressService: progressService, learningEventService: learningEventService)
                    } label: {
                        Label("Quizzes", systemImage: "questionmark.circle.fill")
                    }
                    NavigationLink {
                        PronunciationPracticeView()
                    } label: {
                        Label("Pronunciation", systemImage: "mic.fill")
                    }
                }
            }
            .navigationTitle("Practice")
            .listStyle(.insetGrouped)
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
}


#Preview {
    PracticeView(practiceIntent: .constant(nil))
}
