import AVFoundation
import Foundation
import Speech

enum SpeechRecognitionServiceError: LocalizedError {
    case permissionDenied
    case recognizerUnavailable
    case simulatorLimited
    case noSpeechDetected
    case audioEngineFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Speech recognition or microphone access was denied. Enable both in Settings."
        case .recognizerUnavailable:
            return "On-device speech recognition is unavailable for this locale."
        case .simulatorLimited:
            return "Speech recognition is limited on Simulator; use a physical device."
        case .noSpeechDetected:
            return "No speech was recognized."
        case .audioEngineFailed(let detail):
            return detail
        }
    }
}

@MainActor
final class SpeechRecognitionService {
    static var isSimulatorLimited: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?

    /// Captures a short utterance (up to `maxDuration` seconds) and returns the best transcript.
    func transcribeOnce(maxDuration: TimeInterval = 8) async throws -> String {
        if Self.isSimulatorLimited {
            throw SpeechRecognitionServiceError.simulatorLimited
        }

        let speechStatus = await Self.requestSpeechAuthorization()
        guard speechStatus == .authorized else {
            throw SpeechRecognitionServiceError.permissionDenied
        }

        let micGranted = await Self.requestRecordPermission()
        guard micGranted else {
            throw SpeechRecognitionServiceError.permissionDenied
        }

        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw SpeechRecognitionServiceError.recognizerUnavailable
        }

        return try await transcribeShortUtterance(recognizer: recognizer, maxDuration: maxDuration)
    }

    private func transcribeShortUtterance(
        recognizer: SFSpeechRecognizer,
        maxDuration: TimeInterval
    ) async throws -> String {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        return try await withCheckedThrowingContinuation { continuation in
            var finished = false
            var bestText = ""

            let finish: (Result<String, Error>) -> Void = { [weak self] result in
                guard !finished else { return }
                finished = true
                self?.tearDownRecognition()
                switch result {
                case .success(let text):
                    continuation.resume(returning: text)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if let result {
                    bestText = result.bestTranscription.formattedString
                    if result.isFinal {
                        let trimmed = bestText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            finish(.failure(SpeechRecognitionServiceError.noSpeechDetected))
                        } else {
                            finish(.success(trimmed))
                        }
                    }
                }
                if let error {
                    finish(.failure(error))
                }
            }

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
            }

            do {
                audioEngine.prepare()
                try audioEngine.start()
            } catch {
                finish(.failure(SpeechRecognitionServiceError.audioEngineFailed(error.localizedDescription)))
                return
            }

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(maxDuration * 1_000_000_000))
                request.endAudio()
                try? await Task.sleep(nanoseconds: 500_000_000)
                if !finished {
                    let trimmed = bestText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty {
                        finish(.failure(SpeechRecognitionServiceError.noSpeechDetected))
                    } else {
                        finish(.success(trimmed))
                    }
                }
            }
        }
    }

    private func tearDownRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private static func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private static func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
