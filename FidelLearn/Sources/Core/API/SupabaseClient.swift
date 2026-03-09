import Foundation
import Supabase

/// Supabase client configuration. Reads from environment (Xcode scheme) or Info.plist (embedded at build).
enum SupabaseConfig {
    static var client: SupabaseClient {
        let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"]
            ?? Bundle.main.infoDictionary?["SUPABASE_URL"] as? String
            ?? "https://your-project.supabase.co"
        let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
            ?? Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String
            ?? "your-anon-key"
        let url = URL(string: urlString)!
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
