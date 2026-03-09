import Foundation
import Combine

/// Global app state for authentication and user session.
@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = DefaultAuthService()) {
        self.authService = authService
        setupAuthListener()
    }

    private func setupAuthListener() {
        authService.sessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                self?.isAuthenticated = session != nil
                self?.currentUser = session.map { User(id: $0.user.id.uuidString, email: $0.user.email, createdAt: nil, updatedAt: nil) }
            }
            .store(in: &cancellables)

        authService.isAuthResolvingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isResolving in
                self?.isLoading = isResolving
            }
            .store(in: &cancellables)
    }

    func signOut() async {
        await authService.signOut()
    }
}
