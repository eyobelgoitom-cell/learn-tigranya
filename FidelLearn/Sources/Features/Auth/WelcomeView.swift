import SwiftUI

/// Premium landing screen — first thing users see.
/// Get Started → Sign Up. Sign In → Sign In. Dashboard only after auth success.
struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showAuth = false
    @State private var authMode: AuthView.AuthMode = .signUp
    @State private var appeared = false

    var body: some View {
        ZStack {
            backgroundLayer
            contentLayer
        }
        .fullScreenCover(isPresented: $showAuth) {
            AuthView(initialMode: authMode) {
                hasCompletedOnboarding = true
            }
            .environmentObject(appState)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            // Subtle radial gradient — warm, premium
            RadialGradient(
                colors: [
                    FidelTheme.accent.opacity(0.12),
                    FidelTheme.accent.opacity(0.04),
                    Color.clear,
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Secondary accent glow
            RadialGradient(
                colors: [
                    FidelTheme.accentLight.opacity(0.06),
                    Color.clear,
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    private var contentLayer: some View {
        VStack(spacing: 0) {
            Spacer()

            heroSection

            Spacer()
                .frame(height: 48)

            actionsSection

            Spacer()
                .frame(height: 48)
        }
        .padding(.horizontal, 32)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 28) {
            // Fidel mark — large, centered, cultural
            Text("ሰላም")
                .font(.system(size: 88, weight: .medium))
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                Text("Fidel Learn")
                    .font(FidelTheme.titleLarge)
                    .foregroundStyle(.primary)

                Text("Master Tigrinya and Amharic\nthrough the beautiful Ge'ez script")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 16) {
            Button {
                authMode = .signUp
                showAuth = true
            } label: {
                Text("Get Started")
                    .font(FidelTheme.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .minTouchTarget()
            }
            .buttonStyle(.borderedProminent)
            .tint(FidelTheme.accent)
            .accessibilityLabel("Get started")
            .accessibilityHint("Create an account to start learning")

            Button {
                authMode = .signIn
                showAuth = true
            } label: {
                HStack(spacing: 8) {
                    Text("Sign In")
                        .font(FidelTheme.headline)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .minTouchTarget()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(FidelTheme.accent)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(FidelTheme.accent.opacity(0.5), lineWidth: 1.5)
            )
            .accessibilityLabel("Sign in")
            .accessibilityHint("Sign in to sync your progress")
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
