import SwiftUI

/// Root navigation container with tab-based layout.
struct RootView: View {
    @State private var selectedTab: RootTab = .home
    @Environment(\.progressService) private var progressService

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(progressService: progressService, selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(RootTab.home)

            LessonsView()
                .tabItem { Label("Lessons", systemImage: "book.fill") }
                .tag(RootTab.lessons)

            PracticeView()
                .tabItem { Label("Practice", systemImage: "brain.head.profile") }
                .tag(RootTab.practice)

            UserProgressView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(RootTab.progress)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(RootTab.settings)
        }
        .tint(.accentColor)
    }
}

enum RootTab: Hashable {
    case home, lessons, practice, progress, settings
}

#Preview {
    RootView()
}
