import Foundation

/// SpeechRecognitionBridge seam: mic + STT → CoachChat input. Host wiring is Builder's.
/// Preparation owns the session transcript model and feed-into-chat boundary only.
@MainActor
public final class SpeechRecognitionBridge {
    public private(set) var session: SpeechCaptureSession

    public init(session: SpeechCaptureSession = SpeechCaptureSession()) {
        self.session = session
    }

    public func beginListening() {
        session.isListening = true
        if session.transcript.isEmpty {
            session.startedAt = Date()
        }
    }

    public func appendTranscript(_ fragment: String) {
        let trimmed = fragment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if session.transcript.isEmpty {
            session.transcript = trimmed
        } else {
            session.transcript += " " + trimmed
        }
    }

    public func stopListening() {
        session.isListening = false
    }

    /// Feed recognized text into coach chat prompt ownership (caller persists CoachTurn).
    public func consumeTranscriptForChat() -> String {
        let text = session.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        session.transcript = ""
        session.isListening = false
        return text
    }
}
