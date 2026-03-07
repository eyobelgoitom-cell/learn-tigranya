import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if appState.isAuthenticated {
                        HStack {
                            Text(appState.currentUser?.email ?? "User")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Sign Out", role: .destructive) {
                                Task { await appState.signOut() }
                            }
                        }
                    } else {
                        Button("Sign In") {
                            viewModel.showSignIn = true
                        }
                    }
                }

                Section("Learning") {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        Text("Tigrinya").tag(LearningLanguage.tigrinya)
                        Text("Amharic").tag(LearningLanguage.amharic)
                    }
                    Picker("Audio Speed", selection: $viewModel.audioSpeed) {
                        Text("Slow").tag(AudioSpeed.slow)
                        Text("Normal").tag(AudioSpeed.normal)
                        Text("Fast").tag(AudioSpeed.fast)
                    }
                }

                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
                }

                Section("Data") {
                    Button("Clear Cache") {
                        viewModel.clearCache()
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
