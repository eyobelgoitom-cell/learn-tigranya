import SwiftUI

struct PracticeView: View {
    @Environment(\.progressService) private var progressService
    @StateObject private var viewModel = PracticeViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Practice Modes") {
                    NavigationLink {
                        FlashcardPracticeView()
                    } label: {
                        Label("Flashcards", systemImage: "rectangle.stack.fill")
                    }
                    NavigationLink {
                        QuizPracticeView(progressService: progressService)
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
        }
    }
}

struct PronunciationPracticeView: View {
    var body: some View {
        Text("Pronunciation")
            .navigationTitle("Pronunciation")
    }
}

#Preview {
    PracticeView()
}
