import SwiftUI

struct UserProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsGrid
                    achievementsSection
                }
                .padding()
            }
            .navigationTitle("Progress")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Words Learned", value: "\(viewModel.wordsLearned)")
            StatCard(title: "Lessons Completed", value: "\(viewModel.lessonsCompleted)")
            StatCard(title: "Current Streak", value: "\(viewModel.streak) days")
            StatCard(title: "Accuracy", value: "\(Int(viewModel.accuracy * 100))%")
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
            ForEach(viewModel.achievements, id: \.id) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack {
            Image(systemName: achievement.isUnlocked ? "star.fill" : "star")
                .foregroundStyle(achievement.isUnlocked ? .yellow : .gray)
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    UserProgressView()
}
