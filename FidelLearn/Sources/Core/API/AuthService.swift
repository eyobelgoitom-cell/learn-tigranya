import Foundation
@preconcurrency import Combine
import Supabase

protocol AuthServiceProtocol: Sendable {
    var sessionPublisher: AnyPublisher<Session?, Never> { get }
    var isAuthResolvingPublisher: AnyPublisher<Bool, Never> { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async
}

final class SupabaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let client: SupabaseClient
    private let sessionSubject = CurrentValueSubject<Session?, Never>(nil)
    private let isAuthResolvingSubject = CurrentValueSubject<Bool, Never>(true)

    var sessionPublisher: AnyPublisher<Session?, Never> {
        sessionSubject.eraseToAnyPublisher()
    }

    var isAuthResolvingPublisher: AnyPublisher<Bool, Never> {
        isAuthResolvingSubject.eraseToAnyPublisher()
    }

    init(client: SupabaseClient = SupabaseConfig.client) {
        self.client = client
        Task { [weak self] in
            guard let self else { return }
            for await (event, session) in self.client.auth.authStateChanges {
                switch event {
                case .initialSession:
                    if let session, session.isExpired {
                        isAuthResolvingSubject.send(true)
                        sessionSubject.send(nil)
                    } else {
                        isAuthResolvingSubject.send(false)
                        sessionSubject.send(session)
                    }
                case .tokenRefreshed, .signedIn:
                    isAuthResolvingSubject.send(false)
                    sessionSubject.send(session)
                case .signedOut:
                    isAuthResolvingSubject.send(false)
                    sessionSubject.send(session)
                @unknown default:
                    isAuthResolvingSubject.send(false)
                    sessionSubject.send(session)
                }
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
