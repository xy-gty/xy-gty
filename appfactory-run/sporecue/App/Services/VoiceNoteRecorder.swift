import AVFoundation
import Foundation

@MainActor
final class VoiceNoteRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var lastError: String?

    private var recorder: AVAudioRecorder?
    private var outputURL: URL?

    func start(to directory: URL) {
        lastError = nil
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            let url = directory.appendingPathComponent("voice-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            outputURL = url
            isRecording = true
        } catch {
            lastError = error.localizedDescription
            isRecording = false
        }
    }

    func stop() -> URL? {
        recorder?.stop()
        isRecording = false
        let url = outputURL
        recorder = nil
        outputURL = nil
        return url
    }
}
