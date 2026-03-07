import SwiftUI

/// Root navigation container with tab-based layout.
struct RootView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(Tab.home)

            LessonsView()
                .tabItem { Label("Lessons", systemImage: "book.fill") }
                .tag(Tab.lessons)

            PracticeView()
                .tabItem { Label("Practice", systemImage: "brain.head.profile") }
                .tag(Tab.practice)

            UserProgressView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(Tab.progress)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(.accentColor)
    }
}

private enum Tab: Hashable {
    case home, lessons, practice, progress, settings
}

#Preview {
    RootView()
}
