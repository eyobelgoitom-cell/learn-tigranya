import Foundation
@preconcurrency import Combine
import Supabase

/// Default auth service - uses Supabase when configured.
/// Falls back to no session when Supabase URL is not configured (offline/dev).
final class DefaultAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let supabaseAuth = SupabaseAuthService()

    var sessionPublisher: AnyPublisher<Session?, Never> {
        let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        let isConfigured = !url.isEmpty && !url.contains("your-project")
        if isConfigured {
            return supabaseAuth.sessionPublisher
        }
        return Just(nil).eraseToAnyPublisher()
    }

    var isAuthResolvingPublisher: AnyPublisher<Bool, Never> {
        let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        let isConfigured = !url.isEmpty && !url.contains("your-project")
        if isConfigured {
            return supabaseAuth.isAuthResolvingPublisher
        }
        return Just(false).eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) async throws {
        try await supabaseAuth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await supabaseAuth.signUp(email: email, password: password)
    }

    func signOut() async {
        await supabaseAuth.signOut()
    }
}
