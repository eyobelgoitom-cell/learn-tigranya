import SwiftUI

@main
struct FidelLearnApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environment(\.progressService, SyncProgressService(appState: appState))
                .overlay {
                    if appState.isLoading {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: appState.isLoading)
        }
    }
}
