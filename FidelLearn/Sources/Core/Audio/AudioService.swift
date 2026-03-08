import AVFoundation
import Foundation

/// Protocol for audio playback (pronunciation).
@MainActor
protocol AudioServiceProtocol {
    func play(text: String) async
    func stop()
}

/// TTS-based audio service. Speaks transliteration for Fidel characters and words.
/// Uses AVSpeechSynthesizer — speaks Latin transliteration (e.g., "ha", "selam").
@MainActor
final class AudioService: AudioServiceProtocol {
    static let shared = AudioService()
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?

    private init() {}

    func play(text: String) async {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        currentUtterance = utterance
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        currentUtterance = nil
    }
}
