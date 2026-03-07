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

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: LearningLanguage = .tigrinya
    @Published var audioSpeed: AudioSpeed = .normal
    @Published var isDarkMode = false
    @Published var showSignIn = false

    func clearCache() {
        // TODO: Clear cached lessons, audio, vocabulary
    }
}
