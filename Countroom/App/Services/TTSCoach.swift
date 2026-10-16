import AVFoundation
import Foundation

@MainActor
final class TTSCoach: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speakCountIn(then tip: String?) {
        stop()
        let utterance = AVSpeechUtterance(string: "Three. Two. One. Begin.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        synthesizer.speak(utterance)
        if let tip, !tip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let tipUtterance = AVSpeechUtterance(string: tip)
            tipUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            tipUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
            synthesizer.speak(tipUtterance)
        }
        isSpeaking = true
    }

    func speakTip(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            if !self.synthesizer.isSpeaking {
                self.isSpeaking = false
            }
        }
    }
}
