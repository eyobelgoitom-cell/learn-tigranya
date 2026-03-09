import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    @AppStorage("colorScheme") private var colorSchemeRaw = ColorSchemeOption.system.rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if appState.isAuthenticated {
                        HStack(spacing: FidelTheme.spaceM) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundStyle(FidelTheme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(appState.currentUser?.email ?? "User")
                                    .font(FidelTheme.headline)
                                Text("Signed in")
                                    .font(FidelTheme.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Sign Out", role: .destructive) {
                                Task { await appState.signOut() }
                            }
                        }
                        .padding(.vertical, FidelTheme.spaceXS)
                    } else {
                        Button {
                            viewModel.showSignIn = true
                        } label: {
                            Label("Sign In", systemImage: "person.badge.plus")
                        }
                    }
                } header: {
                    Text("Account")
                }

                Section {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        Text("Tigrinya").tag(LearningLanguage.tigrinya)
                        Text("Amharic").tag(LearningLanguage.amharic)
                    }
                    Picker("Audio Speed", selection: $viewModel.audioSpeed) {
                        Text("Slow").tag(AudioSpeed.slow)
                        Text("Normal").tag(AudioSpeed.normal)
                        Text("Fast").tag(AudioSpeed.fast)
                    }
                } header: {
                    Text("Learning")
                }

                Section {
                    Picker("Color Scheme", selection: $colorSchemeRaw) {
                        ForEach(ColorSchemeOption.allCases, id: \.rawValue) { option in
                            Text(option.rawValue).tag(option.rawValue)
                        }
                    }
                } header: {
                    Text("Appearance")
                }

                Section {
                    Button {
                        viewModel.clearCache()
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                    }
                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        Label("Show Welcome Again", systemImage: "hand.wave")
                    }
                } header: {
                    Text("Data")
                }
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $viewModel.showSignIn) {
                AuthView()
                    .environmentObject(appState)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
