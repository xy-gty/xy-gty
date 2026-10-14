import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

/// CoachingTTS interface: AVSpeechSynthesizer seam; step ownership stays with product.
@MainActor
public final class CoachingTTS {
    public enum Failure: Error {
        case emptySteps
        case stepOutOfRange
    }

#if canImport(AVFoundation)
    private let synthesizer = AVSpeechSynthesizer()
#endif

    public init() {}

    public func speak(step: CoachingStep, steps: [CoachingStep]) throws {
        guard !steps.isEmpty else { throw Failure.emptySteps }
        guard steps.contains(where: { $0.id == step.id }) else { throw Failure.stepOutOfRange }
        let line = step.utterance
#if canImport(AVFoundation)
        let utterance = AVSpeechUtterance(string: line)
        utterance.voice = AVSpeechSynthesisVoice(language: BendCoachIdentity.uiLanguage)
        synthesizer.speak(utterance)
#else
        _ = line
#endif
    }

    public func speakOrderedSteps(_ steps: [CoachingStep], at index: Int) throws {
        guard !steps.isEmpty else { throw Failure.emptySteps }
        let ordered = steps.sorted { $0.orderIndex < $1.orderIndex }
        guard ordered.indices.contains(index) else { throw Failure.stepOutOfRange }
        try speak(step: ordered[index], steps: ordered)
    }

    public func stop() {
#if canImport(AVFoundation)
        synthesizer.stopSpeaking(at: .immediate)
#endif
    }

    public func nextIndex(after index: Int, stepCount: Int) -> Int? {
        let next = index + 1
        guard next < stepCount else { return nil }
        return next
    }
}
