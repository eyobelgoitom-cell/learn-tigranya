import Foundation
@preconcurrency import Combine
import Supabase

protocol AuthServiceProtocol: Sendable {
    var sessionPublisher: AnyPublisher<Session?, Never> { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async
}

final class SupabaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let client: SupabaseClient
    private let sessionSubject = CurrentValueSubject<Session?, Never>(nil)

    var sessionPublisher: AnyPublisher<Session?, Never> {
        sessionSubject.eraseToAnyPublisher()
    }

    init(client: SupabaseClient = SupabaseConfig.client) {
        self.client = client
        Task { [weak self] in
            guard let self else { return }
            for await (_, session) in self.client.auth.authStateChanges {
                self.sessionSubject.send(session)
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }

    func signOut() async {
        try? await client.auth.signOut()
    }
}
