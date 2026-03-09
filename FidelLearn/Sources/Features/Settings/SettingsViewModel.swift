import Foundation
import SwiftUI

enum LearningLanguage: String, CaseIterable {
    case tigrinya
    case amharic
}

enum AudioSpeed: String, CaseIterable {
    case slow
    case normal
    case fast
}

enum ColorSchemeOption: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: LearningLanguage = .tigrinya
    @Published var audioSpeed: AudioSpeed = .normal
    @Published var showSignIn = false

    func clearCache() {
        // TODO: Clear cached lessons, audio, vocabulary
    }
}
