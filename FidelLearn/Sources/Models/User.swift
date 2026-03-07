import Foundation

/// App user model (maps to Supabase auth.users + public.users).
struct User: Identifiable, Codable {
    let id: String
    let email: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
