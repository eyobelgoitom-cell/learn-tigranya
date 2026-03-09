import SwiftUI

/// Premium Sign In / Sign Up — full-screen, refined, high-end.
struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var initialMode: AuthMode = .signIn
    var onAuthSuccess: (() -> Void)?

    @State private var mode: AuthMode
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var appeared = false

    init(initialMode: AuthMode = .signIn, onAuthSuccess: (() -> Void)? = nil) {
        self.initialMode = initialMode
        self.onAuthSuccess = onAuthSuccess
        _mode = State(initialValue: initialMode)
    }

    enum AuthMode: String, CaseIterable {
        case signIn = "Sign In"
        case signUp = "Create Account"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        headerSection
                        formSection
                        if let error = errorMessage {
                            errorBanner(error)
                        }
                        primaryButton
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }

    private var backgroundLayer: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(spacing: FidelTheme.spaceM) {
            ZStack {
                RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                    .fill(FidelTheme.accent.opacity(0.1))
                    .square(80)
                Text("ሰላም")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(FidelTheme.accent)
            }
            Text("Fidel Learn")
                .font(FidelTheme.title)
                .foregroundStyle(.secondary)
        }
        .padding(.top, FidelTheme.spaceL)
    }

    private var formSection: some View {
        VStack(spacing: 24) {
            // Demo sign-in — subtle, premium
            Button {
                Task { await signInAsDemo() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 20))
                    Text("Sign in as Demo")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .disabled(isLoading)
            .accessibilityLabel("Sign in as demo user")

            HStack {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1)
                Text("or continue with email")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.tertiary)
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1)
            }

            // Mode toggle — pill style
            HStack(spacing: 0) {
                ForEach(AuthMode.allCases, id: \.self) { m in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            mode = m
                            errorMessage = nil
                        }
                    } label: {
                        Text(m.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(mode == m ? .white : .secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(mode == m ? FidelTheme.accent : Color.clear)
                    )
                }
            }
            .padding(4)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Fields — refined
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .padding(.horizontal, 20)
                    .frame(height: 52)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .padding(.horizontal, 20)
                    .frame(height: 52)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .textContentType(mode == .signUp ? .newPassword : .password)

                if mode == .signUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.plain)
                        .font(.system(size: 17))
                        .padding(.horizontal, 20)
                        .frame(height: 52)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .textContentType(.newPassword)
                }
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundStyle(FidelTheme.error)
            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(FidelTheme.error)
            Spacer()
        }
        .padding(16)
        .background(FidelTheme.error.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var primaryButton: some View {
        Button {
            Task { await submit() }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(mode == .signIn ? "Sign In" : "Create Account")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .minTouchTarget()
        }
        .buttonStyle(.borderedProminent)
        .tint(FidelTheme.accent)
        .disabled(isLoading || !isFormValid)
        .accessibilityLabel(mode == .signIn ? "Sign in" : "Create account")
    }

    private var isFormValid: Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        if mode == .signUp {
            return password.count >= 6 && password == confirmPassword
        }
        return true
    }

    private func submit() async {
        errorMessage = nil
        guard isFormValid else {
            errorMessage = "Please fill all fields."
            if mode == .signUp && password != confirmPassword {
                errorMessage = "Passwords do not match."
            }
            if mode == .signUp && password.count < 6 {
                errorMessage = "Password must be at least 6 characters."
            }
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            switch mode {
            case .signIn:
                try await appState.signIn(email: email, password: password)
            case .signUp:
                try await appState.signUp(email: email, password: password)
            }
            onAuthSuccess?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func signInAsDemo() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await appState.signIn(email: "demo@fidellearn.com", password: "demo123456")
            onAuthSuccess?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
