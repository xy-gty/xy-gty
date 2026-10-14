import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

/// HandsFreeTTS interface: AVSpeechSynthesizer seam; step-plan ownership stays with product.
@MainActor
public final class HandsFreeTTS {
    public enum Failure: Error {
        case emptySteps
        case indexOutOfRange
    }

#if canImport(AVFoundation)
    private let synthesizer = AVSpeechSynthesizer()
#endif

    public init() {}

    public func speak(plan: HandsFreePlan, at index: Int) throws {
        guard !plan.steps.isEmpty else { throw Failure.emptySteps }
        guard plan.steps.indices.contains(index) else { throw Failure.indexOutOfRange }
        let line = plan.steps[index]
#if canImport(AVFoundation)
        let utterance = AVSpeechUtterance(string: line)
        utterance.voice = AVSpeechSynthesisVoice(language: KnotCueIdentity.uiLanguage)
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

    public func nextIndex(after index: Int, stepCount: Int) -> Int? {
        let next = index + 1
        guard next < stepCount else { return nil }
        return next
    }
}
