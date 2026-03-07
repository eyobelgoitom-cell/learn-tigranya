import SwiftUI

struct PracticeView: View {
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
                        QuizPracticeView()
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

struct FlashcardPracticeView: View {
    var body: some View {
        Text("Flashcards")
            .navigationTitle("Flashcards")
    }
}

struct QuizPracticeView: View {
    var body: some View {
        Text("Quizzes")
            .navigationTitle("Quizzes")
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
