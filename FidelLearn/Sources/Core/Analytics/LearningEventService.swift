import Foundation
import SwiftUI

/// Records learning events for analytics, insights, and recommendations.
/// Events are stored locally first and synced to Supabase when authenticated.
protocol LearningEventServiceProtocol: Sendable {
    func record(_ event: LearningEvent) async
}

/// Local-first event storage. Queues events in UserDefaults, syncs when authenticated.
final class SyncLearningEventService: LearningEventServiceProtocol, @unchecked Sendable {
    private let local: LocalLearningEventService
    private let getIsAuthenticated: @Sendable () async -> Bool

    init(
        local: LocalLearningEventService = LocalLearningEventService(),
        getIsAuthenticated: @escaping @Sendable () async -> Bool
    ) {
        self.local = local
        self.getIsAuthenticated = getIsAuthenticated
    }

    @MainActor
    convenience init(appState: AppState) {
        self.init(getIsAuthenticated: {
            await MainActor.run { appState.isAuthenticated }
        })
    }

    func record(_ event: LearningEvent) async {
        await local.record(event)
        if await getIsAuthenticated() {
            await local.flushToRemote()
        }
    }
}

// MARK: - Environment

private struct LearningEventServiceKey: EnvironmentKey {
    static let defaultValue: SyncLearningEventService = SyncLearningEventService(getIsAuthenticated: { false })
}

extension EnvironmentValues {
    var learningEventService: SyncLearningEventService {
        get { self[LearningEventServiceKey.self] }
        set { self[LearningEventServiceKey.self] = newValue }
    }
}
