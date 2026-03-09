import SwiftUI

struct HomeView: View {
    let progressService: SyncProgressService
    @Binding var selectedTab: RootTab
    @Binding var practiceIntent: PracticeIntent?
    @StateObject private var viewModel: HomeViewModel
    @State private var appeared = false

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
                withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
            Text(greeting)
                .font(FidelTheme.titleLarge)
                .foregroundStyle(.primary)
            Text("Ready to learn today?")
                .font(FidelTheme.body)
                .foregroundStyle(.secondary)
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
                    .animation(.easeOut(duration: 0.35).delay(Double(index) * 0.05), value: appeared)
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
                        .frame(width: 52, height: 52)
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.isStreakAtRisk ? FidelTheme.error : FidelTheme.streak)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                    Text("\(viewModel.streak) day streak")
                        .font(FidelTheme.headline)
                    Text(viewModel.isStreakAtRisk ? "Don't break it — quick lesson?" : "Keep learning!")
                        .font(FidelTheme.caption)
                        .foregroundStyle(viewModel.isStreakAtRisk ? FidelTheme.error : .secondary)
                }
                Spacer()
                if viewModel.streak >= 7 {
                    Text("🔥")
                        .font(.title2)
                }
            }
            .padding(FidelTheme.spaceM)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.streak) day streak. \(viewModel.isStreakAtRisk ? "At risk" : "Keep learning.")")
        }
    }

    private var dailyGoalCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
                HStack {
                    Text("Daily Goal")
                        .font(FidelTheme.headline)
                    Spacer()
                    Text("\(viewModel.lessonsCompletedToday)/\(viewModel.dailyGoal)")
                        .font(FidelTheme.title)
                        .foregroundStyle(FidelTheme.accent)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(FidelTheme.accent)
                            .frame(width: max(0, geo.size.width * viewModel.dailyProgress), height: 12)
                            .animation(.easeOut(duration: 0.5), value: viewModel.dailyProgress)
                    }
                }
                .frame(height: 12)
            }
            .padding(FidelTheme.spaceM)
        }
    }

    private var continueLessonCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: FidelTheme.spaceM) {
                Text("Continue Learning")
                    .font(FidelTheme.headline)
                if let lesson = viewModel.nextLesson {
                    Text(lesson.title)
                        .font(FidelTheme.body)
                        .foregroundStyle(.secondary)
                    Button {
                        selectedTab = .lessons
                    } label: {
                        Label("Continue", systemImage: "arrow.right")
                            .font(FidelTheme.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, FidelTheme.spaceM)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FidelTheme.accent)
                    .accessibilityLabel("Continue to \(lesson.title)")
                    .accessibilityHint("Opens the lessons tab to start this lesson")
                } else {
                    Text("Start your first lesson!")
                        .font(FidelTheme.body)
                        .foregroundStyle(.secondary)
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
