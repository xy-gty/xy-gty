import Foundation
import Speech
import AVFoundation

/// On-device speech recognition for Voice supplement drafts. Does not outbound-send audio.
@MainActor
final class VoiceSupplementSession: NSObject, ObservableObject {
    enum Target: String, Codable {
        case actionSupplement
        case briefingQuestion
    }

    @Published var isListening = false
    @Published var partialTranscript = ""
    @Published var lastError: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let engine = AVAudioEngine()

    var isRecognizerAvailable: Bool {
        recognizer?.isAvailable == true
    }

    func requestAuthorizations() async -> Bool {
        let speech = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
        guard speech else {
            lastError = "Speech recognition not authorized."
            return false
        }
        let mic = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
        if !mic {
            lastError = "Microphone not authorized."
        }
        return mic
    }

    func start() async {
        stop()
        lastError = nil
        partialTranscript = ""
        guard await requestAuthorizations() else { return }
        guard let recognizer, recognizer.isAvailable else {
            lastError = "Speech recognizer unavailable on this device."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            engine.prepare()
            try engine.start()
            isListening = true
            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let result {
                        self.partialTranscript = result.bestTranscription.formattedString
                    }
                    if let error {
                        self.lastError = error.localizedDescription
                        self.stop()
                    } else if result?.isFinal == true {
                        self.stop()
                    }
                }
            }
        } catch {
            lastError = error.localizedDescription
            stop()
        }
    }

    func stop() {
        if engine.isRunning {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isListening = false
    }
}
