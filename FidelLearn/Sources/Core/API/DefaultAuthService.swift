import Foundation
@preconcurrency import Combine
import Supabase

/// Default auth service - uses Supabase when configured.
/// Falls back to no session when Supabase URL is not configured (offline/dev).
final class DefaultAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let supabaseAuth = SupabaseAuthService()

    private var isSupabaseConfigured: Bool {
        let url = ProcessInfo.processInfo.environment["SUPABASE_URL"]
            ?? Bundle.main.infoDictionary?["SUPABASE_URL"] as? String
            ?? ""
        return !url.isEmpty && !url.contains("your-project")
    }

    var sessionPublisher: AnyPublisher<Session?, Never> {
        if isSupabaseConfigured {
            return supabaseAuth.sessionPublisher
        }
        return Just(nil).eraseToAnyPublisher()
    }

    var isAuthResolvingPublisher: AnyPublisher<Bool, Never> {
        if isSupabaseConfigured {
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
