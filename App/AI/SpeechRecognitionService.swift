import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechRecognitionService {
    enum Failure: LocalizedError {
        case unavailable
        case denied
        case noResult

        var errorDescription: String? {
            switch self {
            case .unavailable: return "Speech recognition unavailable on this device."
            case .denied: return "Speech permission denied — type your goal instead."
            case .noResult: return "No speech captured."
            }
        }
    }

    func recognizeOnce(maxSeconds: TimeInterval = 8) async throws -> String {
        let auth = await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { cont.resume(returning: $0) }
        }
        guard auth == .authorized else { throw Failure.denied }
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")),
              recognizer.isAvailable else {
            throw Failure.unavailable
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [])
        try session.setActive(true)

        let engine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else {
            // Simulator without mic — honest failure so UI keeps typing path.
            throw Failure.unavailable
        }
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        engine.prepare()
        try engine.start()

        return try await withCheckedThrowingContinuation { cont in
            var finished = false
            let task = recognizer.recognitionTask(with: request) { result, error in
                guard !finished else { return }
                if let error {
                    finished = true
                    engine.stop()
                    input.removeTap(onBus: 0)
                    cont.resume(throwing: error)
                    return
                }
                if let result, result.isFinal {
                    finished = true
                    engine.stop()
                    input.removeTap(onBus: 0)
                    let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if text.isEmpty {
                        cont.resume(throwing: Failure.noResult)
                    } else {
                        cont.resume(returning: text)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + maxSeconds) {
                guard !finished else { return }
                request.endAudio()
                task.finish()
            }
        }
    }
}
