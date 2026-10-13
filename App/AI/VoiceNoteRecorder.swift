import AVFoundation
import Foundation

enum VoiceNoteRecorderError: LocalizedError {
    case permissionDenied
    case simulatorLimited
    case notRecording
    case alreadyRecording
    case recorderFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access was denied. Enable it in Settings to record voice notes."
        case .simulatorLimited:
            return "Microphone voice notes are limited on Simulator; use a physical device."
        case .notRecording:
            return "No voice note is currently recording."
        case .alreadyRecording:
            return "A voice note is already recording."
        case .recorderFailed(let detail):
            return detail
        }
    }
}

@MainActor
final class VoiceNoteRecorder {
    static var isSimulatorLimited: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private var recorder: AVAudioRecorder?
    private var outputURL: URL?

    func start(to url: URL) async throws {
        if Self.isSimulatorLimited {
            throw VoiceNoteRecorderError.simulatorLimited
        }
        guard recorder == nil else {
            throw VoiceNoteRecorderError.alreadyRecording
        }

        let granted = await Self.requestRecordPermission()
        guard granted else {
            throw VoiceNoteRecorderError.permissionDenied
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try session.setActive(true)

        let parent = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let instance = try AVAudioRecorder(url: url, settings: settings)
        guard instance.prepareToRecord(), instance.record() else {
            throw VoiceNoteRecorderError.recorderFailed("Could not start microphone recording.")
        }

        recorder = instance
        outputURL = url
    }

    func stop() async throws -> URL {
        if Self.isSimulatorLimited {
            throw VoiceNoteRecorderError.simulatorLimited
        }
        guard let active = recorder, let url = outputURL else {
            throw VoiceNoteRecorderError.notRecording
        }

        active.stop()
        recorder = nil
        outputURL = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return url
    }

    private static func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
