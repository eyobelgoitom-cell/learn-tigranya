import SwiftUI

@main
struct FidelLearnApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environment(\.progressService, SyncProgressService(appState: appState))
        }
    }
}
