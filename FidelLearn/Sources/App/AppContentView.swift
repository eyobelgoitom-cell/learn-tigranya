import SwiftUI

/// Root content: onboarding vs main app, with dark mode applied.
struct AppContentView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("colorScheme") private var colorSchemeRaw = ColorSchemeOption.system.rawValue

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                RootView()
            } else {
                WelcomeView()
            }
        }
        .preferredColorScheme(resolvedColorScheme)
    }

    private var resolvedColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case ColorSchemeOption.light.rawValue: return .light
        case ColorSchemeOption.dark.rawValue: return .dark
        default: return nil
        }
    }
}
