import Foundation
import Supabase

/// Supabase client configuration. Keys should come from environment/Config.
enum SupabaseConfig {
    static var client: SupabaseClient {
        let url = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://your-project.supabase.co")!
        let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "your-anon-key"
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }
}
