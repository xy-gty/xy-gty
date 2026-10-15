import AVFoundation
import Foundation

@MainActor
final class VoiceNoteRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var lastError: String?
    private var recorder: AVAudioRecorder?

    func requestMicAccess() async -> Bool {
        await withCheckedContinuation { cont in
            AVAudioSession.sharedInstance().requestRecordPermission { ok in
                cont.resume(returning: ok)
            }
        }
    }

    func start(to url: URL) {
        lastError = nil
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
            try session.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
            ]
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            isRecording = true
        } catch {
            lastError = error.localizedDescription
            isRecording = false
        }
    }

    func stop() {
        recorder?.stop()
        recorder = nil
        isRecording = false
    }
}
