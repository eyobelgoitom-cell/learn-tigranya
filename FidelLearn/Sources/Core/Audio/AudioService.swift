import AVFoundation
import Foundation

/// Protocol for audio playback (pronunciation).
@MainActor
protocol AudioServiceProtocol {
    func play(text: String) async
    func play(url: URL?, completion: (() -> Void)?) async
    func stop()
}

/// TTS-based audio service. Speaks transliteration for Fidel characters and words.
/// Uses AVSpeechSynthesizer — speaks Latin transliteration (e.g., "ha", "selam").
/// Supports URL playback for native speaker audio when available.
@MainActor
final class AudioService: AudioServiceProtocol {
    static let shared = AudioService()
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var currentPlayer: AVPlayer?

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

    func play(url: URL?, completion: (() -> Void)? = nil) async {
        guard let url else { return }
        stop()
        let player = AVPlayer(url: url)
        currentPlayer = player
        player.play()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        currentUtterance = nil
        currentPlayer?.pause()
        currentPlayer = nil
    }
}
