import Foundation
import Combine
import Supabase

protocol AuthServiceProtocol: Sendable {
    var sessionPublisher: AnyPublisher<Session?, Never> { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async
}

final class SupabaseAuthService: AuthServiceProtocol {
    private let client: SupabaseClient

    var sessionPublisher: AnyPublisher<Session?, Never> {
        client.auth.stateChange
            .map(\.session)
            .eraseToAnyPublisher()
    }

    init(client: SupabaseClient = SupabaseConfig.client) {
        self.client = client
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
