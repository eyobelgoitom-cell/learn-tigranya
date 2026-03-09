import SwiftUI

struct HomeView: View {
    let progressService: SyncProgressService
    @Binding var selectedTab: RootTab
    @StateObject private var viewModel: HomeViewModel

    init(progressService: SyncProgressService, selectedTab: Binding<RootTab> = .constant(.home)) {
        self.progressService = progressService
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeViewModel(progressService: progressService))
    }

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
                    .accessibilityHidden(true)
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.streak) day streak. Keep learning.")
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
                        selectedTab = .lessons
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FidelTheme.accent)
                    .accessibilityLabel("Continue to \(lesson.title)")
                    .accessibilityHint("Opens the lessons tab to start this lesson")
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
    HomeView(progressService: SyncProgressService(getIsAuthenticated: { false }))
}
