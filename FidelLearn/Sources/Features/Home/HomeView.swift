import SwiftUI

struct HomeView: View {
    let progressService: SyncProgressService
    @Binding var selectedTab: RootTab
    @Binding var practiceIntent: PracticeIntent?
    @StateObject private var viewModel: HomeViewModel
    @State private var appeared = false
    @State private var streakPulse = false
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
            .navigationBarTitleDisplayMode(.large)
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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: FidelTheme.spaceL) {
                VStack(alignment: .leading, spacing: FidelTheme.spaceS) {
                    Text(greeting)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(viewModel.motivationalMessage)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                    if let summary = viewModel.todaySummary {
                        Text(summary)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                ZStack {
                    RoundedRectangle(cornerRadius: FidelTheme.radiusM)
                        .fill(
                            LinearGradient(
                                colors: [FidelTheme.accent.opacity(0.25), FidelTheme.accent.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .square(64)
                    Text(viewModel.heroFidelCharacter)
                        .font(FidelTheme.fidelFont(size: 40))
                        .foregroundStyle(FidelTheme.accent)
                }
                .shadow(color: FidelTheme.accent.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(FidelTheme.spaceL)
        }
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusXL)
                .fill(FidelTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusXL)
                .stroke(
                    LinearGradient(
                        colors: [FidelTheme.accent.opacity(0.2), FidelTheme.accent.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: FidelTheme.cardShadow, radius: 12, x: 0, y: 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, FidelTheme.spaceS)
    }

    /// Excludes redundant daily goal rec when we already have the daily goal card and other recs.
    private var displayedRecommendations: [Recommendation] {
        let recs = viewModel.recommendations
        if recs.count > 1, recs.contains(where: { $0.id == "daily-goal" }) {
            return recs.filter { $0.id != "daily-goal" }
        }
        return recs
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let base: String
        switch hour {
        case 5..<12: base = "Good morning"
        case 12..<17: base = "Good afternoon"
        default: base = "Good evening"
        }
        if hour >= 20, viewModel.lessonsCompletedToday == 0 {
            return "\(base) — quick 5 min?"
        }
        return base
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceL) {
            Text("For You")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            if viewModel.recommendations.isEmpty {
                continueLessonCard
            } else {
                ForEach(Array(displayedRecommendations.enumerated()), id: \.element.id) { index, rec in
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
                        .scaleEffect(viewModel.isStreakAtRisk && !reduceMotion && streakPulse ? 1.15 : 1)
                }
                .accessibilityHidden(true)
                .onAppear {
                    guard viewModel.isStreakAtRisk, !reduceMotion else { return }
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        streakPulse = true
                    }
                }
                .onChange(of: viewModel.isStreakAtRisk) { atRisk in
                    if !atRisk { streakPulse = false }
                }
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
            return "Your first lesson unlocks your streak."
        }
        if viewModel.streak == 1 {
            return "First day! Keep it going."
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
                HStack(spacing: FidelTheme.spaceL) {
                    ZStack {
                        Circle()
                            .stroke(Color(.tertiarySystemFill), lineWidth: 6)
                            .square(56)
                        Circle()
                            .trim(from: 0, to: min(1, viewModel.dailyProgress))
                            .stroke(
                                viewModel.lessonsCompletedToday >= viewModel.dailyGoal ? FidelTheme.success : FidelTheme.accent,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .square(56)
                            .animation(.easeOut(duration: 0.6), value: viewModel.dailyProgress)
                        if viewModel.lessonsCompletedToday >= viewModel.dailyGoal && viewModel.dailyGoal > 0 {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(FidelTheme.success)
                        } else {
                            Text("\(viewModel.lessonsCompletedToday)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(FidelTheme.accent)
                        }
                    }
                    .frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                        Text("Daily Goal")
                            .font(FidelTheme.headline)
                        Text("\(viewModel.lessonsCompletedToday)/\(viewModel.dailyGoal) lessons")
                            .font(FidelTheme.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tertiary)
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
                HStack(spacing: FidelTheme.spaceM) {
                    ZStack {
                        RoundedRectangle(cornerRadius: FidelTheme.radiusS)
                            .fill(FidelTheme.accent.opacity(0.12))
                            .square(40)
                        Image(systemName: "book.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(FidelTheme.accent)
                    }
                    Text(viewModel.hasProgress ? "Continue Learning" : "Start Learning")
                        .font(FidelTheme.headline)
                    Spacer()
                }
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
