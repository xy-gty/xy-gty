import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

/// MorningBriefingTTS interface: AVSpeechSynthesizer seam; briefing ownership stays with product.
@MainActor
public final class MorningBriefingTTS {
    public enum Failure: Error {
        case emptyUtterances
        case indexOutOfRange
    }

#if canImport(AVFoundation)
    private let synthesizer = AVSpeechSynthesizer()
#endif

    public init() {}

    public func speak(briefing: MorningBriefing, at index: Int) throws {
        guard !briefing.utterances.isEmpty else { throw Failure.emptyUtterances }
        guard briefing.utterances.indices.contains(index) else { throw Failure.indexOutOfRange }
        let line = briefing.utterances[index]
#if canImport(AVFoundation)
        let utterance = AVSpeechUtterance(string: line)
        utterance.voice = AVSpeechSynthesisVoice(language: ClosetCueIdentity.uiLanguage)
        synthesizer.speak(utterance)
#else
        _ = line
#endif
    }

    public func stop() {
#if canImport(AVFoundation)
        synthesizer.stopSpeaking(at: .immediate)
#endif
    }

    public func nextIndex(after index: Int, utteranceCount: Int) -> Int? {
        let next = index + 1
        guard next < utteranceCount else { return nil }
        return next
    }
}
