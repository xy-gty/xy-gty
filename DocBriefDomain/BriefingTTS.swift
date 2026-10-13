import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

/// BriefingTTS interface: AVSpeechSynthesizer seam; session + step index ownership stays with product.
@MainActor
public final class BriefingTTS {
    public enum Failure: Error {
        case emptySession
        case stepOutOfRange
    }

#if canImport(AVFoundation)
    private let synthesizer = AVSpeechSynthesizer()
#endif

    public init() {}

    public func speakCurrentStep(of session: BriefingSession) throws {
        guard !session.utterableLines.isEmpty else { throw Failure.emptySession }
        guard session.utterableLines.indices.contains(session.stepIndex) else {
            throw Failure.stepOutOfRange
        }
        let line = session.utterableLines[session.stepIndex]
#if canImport(AVFoundation)
        let utterance = AVSpeechUtterance(string: line)
        utterance.voice = AVSpeechSynthesisVoice(language: DocBriefIdentity.uiLanguage)
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

    public func advance(_ session: inout BriefingSession) -> Bool {
        let next = session.stepIndex + 1
        guard next < session.utterableLines.count else { return false }
        session.stepIndex = next
        return true
    }
}
