import SwiftUI

struct UserProgressView: View {
    @StateObject private var viewModel: ProgressViewModel
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(progressService: SyncProgressService) {
        _viewModel = StateObject(wrappedValue: ProgressViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FidelTheme.spaceL) {
                    progressHeroSection
                    statsGrid
                    if !viewModel.masteryByGroup.isEmpty {
                        masterySection
                    }
                    achievementsSection
                }
                .padding(FidelTheme.spaceL)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
            }
            .refreshable { viewModel.loadProgress() }
            .navigationTitle("Progress")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                viewModel.loadProgress()
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
                }
            }
        }
    }

    private var progressHeroSection: some View {
        HStack(alignment: .top, spacing: FidelTheme.spaceM) {
            Text("ሀ")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(FidelTheme.accent)
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text("Your Progress")
                    .font(FidelTheme.headline)
                Text(viewModel.motivationalSummary)
                    .font(FidelTheme.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FidelTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .fill(FidelTheme.cardBackground)
        )
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FidelTheme.spaceM) {
            StatCard(title: "Words Learned", value: "\(viewModel.wordsLearned)", icon: "textformat")
            StatCard(title: "Lessons", value: "\(viewModel.lessonsCompleted)", icon: "book.fill")
            StatCard(title: "Streak", value: "\(viewModel.streak) days", icon: "flame.fill")
            StatCard(title: "Accuracy", value: "\(Int(viewModel.accuracy * 100))%", icon: "target")
        }
    }

    private var masterySection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
            Text("Mastery by Row")
                .font(FidelTheme.headline)
            CardView {
                VStack(spacing: FidelTheme.spaceS) {
                    ForEach(viewModel.masteryByGroup.prefix(8), id: \.group) { item in
                        HStack {
                            Text(item.group)
                                .font(FidelTheme.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .leading)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.tertiarySystemFill))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(item.accuracy >= 0.7 ? FidelTheme.success : (item.accuracy >= 0.4 ? FidelTheme.accent : FidelTheme.error.opacity(0.8)))
                                        .frame(width: geo.size.width * item.accuracy)
                                }
                            }
                            .frame(height: 8)
                            Text("\(Int(item.accuracy * 100))%")
                                .font(FidelTheme.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 36, alignment: .trailing)
                        }
                    }
                }
                .padding(FidelTheme.spaceM)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
            Text("Achievements")
                .font(FidelTheme.headline)
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
    var icon: String = "star.fill"

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: FidelTheme.spaceS) {
                HStack(spacing: FidelTheme.spaceS) {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(FidelTheme.accent)
                    Text(title)
                        .font(FidelTheme.caption)
                        .foregroundStyle(.secondary)
                }
                Text(value)
                    .font(FidelTheme.title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(FidelTheme.spaceM)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: FidelTheme.spaceM) {
            Image(systemName: achievement.isUnlocked ? "star.circle.fill" : "star.circle")
                .font(.title2)
                .foregroundStyle(achievement.isUnlocked ? FidelTheme.accent : .secondary)
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text(achievement.title)
                    .font(FidelTheme.headline)
                Text(achievement.description)
                    .font(FidelTheme.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(FidelTheme.spaceM)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
    }
}

#Preview {
    UserProgressView(progressService: SyncProgressService(getIsAuthenticated: { false }))
}
