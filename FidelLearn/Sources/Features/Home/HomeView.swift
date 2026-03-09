import SwiftUI

struct HomeView: View {
    let progressService: SyncProgressService
    @Binding var selectedTab: RootTab
    @Binding var practiceIntent: PracticeIntent?
    @StateObject private var viewModel: HomeViewModel
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(progressService: SyncProgressService, selectedTab: Binding<RootTab> = .constant(.home), practiceIntent: Binding<PracticeIntent?> = .constant(nil)) {
        self.progressService = progressService
        _selectedTab = selectedTab
        _practiceIntent = practiceIntent
        _viewModel = StateObject(wrappedValue: HomeViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FidelTheme.spaceL) {
                    heroSection
                    streakCard
                    dailyGoalCard
                    recommendationsSection
                }
                .padding(FidelTheme.spaceL)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
            }
            .refreshable { viewModel.loadData() }
            .navigationTitle("Fidel Learn")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                viewModel.loadData()
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
            HStack(alignment: .top, spacing: FidelTheme.spaceM) {
                VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                    Text(greeting)
                        .font(FidelTheme.titleLarge)
                        .foregroundStyle(.primary)
                    Text(viewModel.motivationalMessage)
                        .font(FidelTheme.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("ሀ")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(FidelTheme.accent)
            }
            .padding(FidelTheme.spaceM)
            .background(
                RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                    .fill(FidelTheme.cardBackground)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, FidelTheme.spaceS)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
            Text("For You")
                .font(FidelTheme.headline)
                .padding(.horizontal, FidelTheme.spaceXS)
            if viewModel.recommendations.isEmpty {
                continueLessonCard
            } else {
                ForEach(Array(viewModel.recommendations.enumerated()), id: \.element.id) { index, rec in
                    RecommendationCardView(recommendation: rec) {
                        handleRecommendationTap(rec)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.04), value: appeared)
                }
            }
        }
    }

    private func handleRecommendationTap(_ rec: Recommendation) {
        switch rec.action {
        case .reviewWeakLetters:
            practiceIntent = .weakLetters
            selectedTab = .practice
        case .reviewWeakWords:
            practiceIntent = .weakWords
            selectedTab = .practice
        case .completeDailyGoal, .keepStreak:
            selectedTab = .practice
        case .continueLesson:
            selectedTab = .lessons
        }
    }

    private var streakCard: some View {
        CardView {
            HStack(spacing: FidelTheme.spaceM) {
                ZStack {
                    Circle()
                        .fill((viewModel.isStreakAtRisk ? FidelTheme.error : FidelTheme.streak).opacity(0.2))
                        .square(52)
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.isStreakAtRisk ? FidelTheme.error : FidelTheme.streak)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                    HStack(spacing: FidelTheme.spaceXS) {
                        Text("\(viewModel.streak) day streak")
                            .font(FidelTheme.headline)
                        if viewModel.streak == 7 || viewModel.streak == 30 {
                            Text("Milestone!")
                                .font(FidelTheme.caption)
                                .foregroundStyle(FidelTheme.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(FidelTheme.accent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    Text(streakSubtext)
                        .font(FidelTheme.caption)
                        .foregroundStyle(viewModel.isStreakAtRisk ? FidelTheme.error : .secondary)
                }
                Spacer()
                if viewModel.streak >= 7 {
                    Text("🔥")
                        .font(.title2)
                }
                if viewModel.streak >= 30 {
                    Text("⭐")
                        .font(.title2)
                }
            }
            .padding(FidelTheme.spaceM)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.streak) day streak. \(viewModel.streak == 7 || viewModel.streak == 30 ? "Milestone." : "") \(viewModel.isStreakAtRisk ? "At risk" : "Keep learning.")")
        }
    }

    private var streakSubtext: String {
        if viewModel.isStreakAtRisk {
            return "Don't break it — quick lesson?"
        }
        if viewModel.streak >= 30 {
            return "Incredible! 30 days of learning."
        }
        if viewModel.streak >= 7 {
            return "One week strong! Keep it up."
        }
        if viewModel.streak == 0 {
            return "Complete one lesson to start your streak."
        }
        return "Keep learning!"
    }

    private var dailyGoalCard: some View {
        Button {
            HapticService.light()
            if viewModel.lessonsCompletedToday >= viewModel.dailyGoal {
                selectedTab = .practice
            } else {
                selectedTab = .lessons
            }
        } label: {
            CardView {
                VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
                HStack {
                    Text("Daily Goal")
                        .font(FidelTheme.headline)
                    Spacer()
                    if viewModel.lessonsCompletedToday >= viewModel.dailyGoal && viewModel.dailyGoal > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(FidelTheme.success)
                            Text("Done!")
                                .font(FidelTheme.headline)
                                .foregroundStyle(FidelTheme.success)
                        }
                    } else {
                        Text("\(viewModel.lessonsCompletedToday)/\(viewModel.dailyGoal)")
                            .font(FidelTheme.title)
                            .foregroundStyle(FidelTheme.accent)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(viewModel.lessonsCompletedToday >= viewModel.dailyGoal ? FidelTheme.success : FidelTheme.accent)
                            .frame(width: max(0, geo.size.width * viewModel.dailyProgress), height: 12)
                            .animation(.easeOut(duration: 0.5), value: viewModel.dailyProgress)
                    }
                }
                .frame(height: 12)
            }
            .padding(FidelTheme.spaceM)
            }
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel("Daily goal. \(viewModel.lessonsCompletedToday) of \(viewModel.dailyGoal) completed. Tap to \(viewModel.lessonsCompletedToday >= viewModel.dailyGoal ? "practice" : "continue learning").")
    }

    private var continueLessonCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
                Text(viewModel.hasProgress ? "Continue Learning" : "Start Learning")
                    .font(FidelTheme.headline)
                if let lesson = viewModel.nextLesson {
                    VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                        Text(lesson.title)
                            .font(FidelTheme.body)
                            .foregroundStyle(.secondary)
                        if let teaser = viewModel.progressTeaser {
                            Text(teaser)
                                .font(FidelTheme.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    HStack(spacing: FidelTheme.spaceM) {
                        Button {
                            selectedTab = .lessons
                        } label: {
                            Label("Lessons", systemImage: "book.fill")
                                .font(FidelTheme.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, FidelTheme.spaceM)
                                .minTouchTarget()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FidelTheme.accent)
                        .accessibilityLabel("Continue to \(lesson.title)")
                        Button {
                            selectedTab = .practice
                        } label: {
                            Label("Practice", systemImage: "brain.head.profile")
                                .font(FidelTheme.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, FidelTheme.spaceM)
                                .minTouchTarget()
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Practice quiz and flashcards")
                    }
                } else {
                    VStack(alignment: .leading, spacing: FidelTheme.spaceS) {
                        Text("You've completed all lessons!")
                            .font(FidelTheme.body)
                            .foregroundStyle(.secondary)
                        Text("Review with flashcards or quizzes.")
                            .font(FidelTheme.caption)
                            .foregroundStyle(.tertiary)
                        Button {
                            selectedTab = .practice
                        } label: {
                            Label("Practice", systemImage: "brain.head.profile")
                                .font(FidelTheme.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, FidelTheme.spaceM)
                                .minTouchTarget()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FidelTheme.accent)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(FidelTheme.spaceM)
        }
    }
}

#Preview {
    HomeView(progressService: SyncProgressService(getIsAuthenticated: { false }), practiceIntent: .constant(nil))
}
