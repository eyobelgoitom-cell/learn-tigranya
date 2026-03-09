import Foundation

/// Stores learning events locally. Used offline or as queue before sync.
final class LocalLearningEventService: LearningEventServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let maxQueuedEvents = 500
    private let queueKey = "fidel_learn_event_queue"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func record(_ event: LearningEvent) async {
        var queue = loadQueue()
        let record = EventRecord(
            eventType: event.eventType.rawValue,
            payload: event.encodedPayload(),
            createdAt: Date()
        )
        queue.append(record)
        if queue.count > maxQueuedEvents {
            queue = Array(queue.suffix(maxQueuedEvents))
        }
        saveQueue(queue)
    }

    func flushToRemote() async {
        let queue = loadQueue()
        guard !queue.isEmpty else { return }
        do {
            let client = SupabaseConfig.client
            guard let userId = try? await client.auth.session.user.id.uuidString else { return }
            let inserts = queue.map { record in
                LearningEventInsert(
                    userId: userId,
                    eventType: record.eventType,
                    payload: record.payload,
                    createdAt: record.createdAt
                )
            }
            try await client.from("learning_events").insert(inserts).execute()
            saveQueue([])
        } catch {
            // Keep queue for retry
        }
    }

    /// Returns queued + stored events for local insights (e.g. weak items).
    func getRecentEvents(eventType: LearningEvent.LearningEventType? = nil, limit: Int = 200) async -> [EventRecord] {
        let queue = loadQueue()
        var filtered = queue
        if let type = eventType {
            filtered = queue.filter { $0.eventType == type.rawValue }
        }
        return Array(filtered.suffix(limit))
    }

    private func loadQueue() -> [EventRecord] {
        guard let data = defaults.data(forKey: queueKey),
              let decoded = try? JSONDecoder().decode([EventRecord].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveQueue(_ queue: [EventRecord]) {
        if let data = try? JSONEncoder().encode(queue) {
            defaults.set(data, forKey: queueKey)
        }
    }
}

struct EventRecord: Codable, Sendable {
    let eventType: String
    let payload: [String: String]
    let createdAt: Date
}

private struct LearningEventInsert: Encodable {
    let userId: String
    let eventType: String
    let payload: [String: String]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case eventType = "event_type"
        case payload
        case createdAt = "created_at"
    }
}
