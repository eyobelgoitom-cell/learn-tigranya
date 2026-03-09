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
                    if viewModel.isStreakAtRisk {
                        streakAtRiskBanner
                    }
                    if let suggestion = viewModel.nextStepSuggestion {
                        nextStepCard(suggestion)
                    }
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
        HStack(alignment: .center, spacing: FidelTheme.spaceM) {
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 4)
                    .square(56)
                Circle()
                    .trim(from: 0, to: viewModel.accuracy)
                    .stroke(FidelTheme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .square(56)
                    .rotationEffect(.degrees(-90))
                Text("ሀ")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(FidelTheme.accent)
            }
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
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .stroke(FidelTheme.accent.opacity(0.12), lineWidth: 1)
        )
    }

    private var streakAtRiskBanner: some View {
        HStack(spacing: FidelTheme.spaceM) {
            Image(systemName: "flame.fill")
                .foregroundStyle(FidelTheme.error)
            Text("Your \(viewModel.streak)-day streak is at risk. Complete a quick lesson!")
                .font(FidelTheme.callout)
                .foregroundStyle(.primary)
        }
        .padding(FidelTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusM)
                .fill(FidelTheme.error.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusM)
                .stroke(FidelTheme.error.opacity(0.3), lineWidth: 1)
        )
    }

    private func nextStepCard(_ text: String) -> some View {
        HStack(spacing: FidelTheme.spaceM) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(FidelTheme.accent)
            Text(text)
                .font(FidelTheme.callout)
                .foregroundStyle(.secondary)
        }
        .padding(FidelTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusM)
                .fill(FidelTheme.accent.opacity(0.08))
        )
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FidelTheme.spaceM) {
            StatCard(title: "Words Learned", value: "\(viewModel.wordsLearned)", icon: "textformat")
            StatCard(title: "Lessons", value: "\(viewModel.lessonsCompleted)", icon: "book.fill")
            StatCard(title: "Streak", value: viewModel.streak == 1 ? "1 day" : "\(viewModel.streak) days", icon: "flame.fill")
            StatCard(title: "Accuracy", value: "\(Int(viewModel.accuracy * 100))%", icon: "target")
        }
    }

    private var masterySection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
            Label("Mastery by Row", systemImage: "chart.bar.fill")
                .font(FidelTheme.headline)
                .foregroundStyle(.primary)
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
            Label("Achievements", systemImage: "star.fill")
                .font(FidelTheme.headline)
                .foregroundStyle(.primary)
            ForEach(viewModel.achievements, id: \.id) { achievement in
                AchievementRow(achievement: achievement, progressText: progressText(for: achievement))
                    .padding(.bottom, FidelTheme.spaceXS)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func progressText(for achievement: Achievement) -> String? {
        guard !achievement.isUnlocked else { return nil }
        switch achievement.id {
        case "1": return "\(viewModel.lessonsCompleted)/1"
        case "2": return "\(viewModel.streak)/7 days"
        case "3": return "\(viewModel.wordsLearned)/100"
        default: return nil
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var icon: String = "star.fill"

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
                HStack(spacing: FidelTheme.spaceS) {
                    ZStack {
                        RoundedRectangle(cornerRadius: FidelTheme.radiusS)
                            .fill(FidelTheme.accent.opacity(0.15))
                            .square(32)
                        Image(systemName: icon)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(FidelTheme.accent)
                    }
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
    var progressText: String? = nil

    var body: some View {
        HStack(spacing: FidelTheme.spaceM) {
            ZStack {
                RoundedRectangle(cornerRadius: FidelTheme.radiusS)
                    .fill(achievement.isUnlocked ? FidelTheme.accent.opacity(0.2) : Color(.tertiarySystemFill))
                    .square(44)
                Image(systemName: achievement.isUnlocked ? "star.circle.fill" : "star.circle")
                    .font(.title3)
                    .foregroundStyle(achievement.isUnlocked ? FidelTheme.accent : .secondary)
            }
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text(achievement.title)
                    .font(FidelTheme.headline)
                Text(achievement.description)
                    .font(FidelTheme.caption)
                    .foregroundStyle(.secondary)
                if let progress = progressText, !progress.isEmpty {
                    Text(progress)
                        .font(FidelTheme.caption)
                        .foregroundStyle(FidelTheme.accent)
                }
            }
            Spacer()
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(FidelTheme.success)
            }
        }
        .padding(FidelTheme.spaceM)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
    }
}

#Preview {
    UserProgressView(progressService: SyncProgressService(getIsAuthenticated: { false }))
}
