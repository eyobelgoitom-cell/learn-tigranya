import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakCard
                    dailyGoalCard
                    continueLessonCard
                }
                .padding()
            }
            .navigationTitle("Fidel Learn")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var streakCard: some View {
        CardView {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.streak) day streak")
                        .font(.headline)
                    Text("Keep learning!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
        }
    }

    private var dailyGoalCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Goal")
                    .font(.headline)
                ProgressView(value: viewModel.dailyProgress, total: 1)
                    .tint(.accentColor)
                Text("\(viewModel.lessonsCompletedToday)/\(viewModel.dailyGoal) lessons")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private var continueLessonCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Continue Learning")
                    .font(.headline)
                if let lesson = viewModel.nextLesson {
                    Text(lesson.title)
                        .font(.subheadline)
                    Button("Continue") {
                        viewModel.continueLesson()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Start your first lesson!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
