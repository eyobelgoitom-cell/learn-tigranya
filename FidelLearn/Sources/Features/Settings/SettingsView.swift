import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    @AppStorage("colorScheme") private var colorSchemeRaw = ColorSchemeOption.system.rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            List {
                Section {
                    settingsHeaderRow
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

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
                    Label("Account", systemImage: "person.circle")
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
                    Label("Appearance", systemImage: "paintbrush.fill")
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
                    Label("Data", systemImage: "externaldrive.fill")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.easeOut(duration: 0.3)) { appeared = true }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $viewModel.showSignIn) {
                AuthView()
                    .environmentObject(appState)
            }
        }
    }

    private var settingsHeaderRow: some View {
        HStack(alignment: .center, spacing: FidelTheme.spaceM) {
            Text("ሀ")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(FidelTheme.accent)
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text("Fidel Learn")
                    .font(FidelTheme.title)
                Text("Learn Tigrinya & Amharic")
                    .font(FidelTheme.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FidelTheme.spaceM)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .fill(FidelTheme.cardBackground)
        )
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: appeared)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
