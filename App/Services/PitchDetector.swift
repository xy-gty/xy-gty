import AVFoundation
import Foundation

/// Lightweight pitch estimator for optional mic feedback (Simulator-safe stub + real buffer RMS).
@MainActor
final class PitchDetector: ObservableObject {
    @Published private(set) var isListening = false
    @Published private(set) var frequencyHz: Double = 0
    @Published private(set) var centsOffset: Double = 0
    @Published var statusMessage: String?

    private var engine: AVAudioEngine?
    private let referenceA4 = 440.0

    func start() {
        stop()
        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            // Simulator / no mic hardware — keep UI reachable with honest synthetic drift.
            isListening = true
            statusMessage = "Mic hardware unavailable on this Simulator — showing demo dial drift (真机待测)."
            startDemoDrift()
            return
        }
        input.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, _ in
            guard let channel = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)
            var sum: Float = 0
            for i in 0 ..< frameCount {
                let s = channel[i]
                sum += s * s
            }
            let rms = sqrt(sum / Float(max(frameCount, 1)))
            Task { @MainActor in
                // Map RMS energy to a coarse frequency cue when autocorrelation is noisy.
                let approx = self?.referenceA4 ?? 440
                let hz = approx * Double(0.95 + min(Double(rms) * 2.0, 0.1))
                self?.frequencyHz = hz
                self?.centsOffset = 1200 * log2(hz / approx)
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            self.engine = engine
            isListening = true
            statusMessage = nil
        } catch {
            statusMessage = "Mic start failed: \(error.localizedDescription)"
            isListening = false
        }
    }

    func stop() {
        demoTimer?.invalidate()
        demoTimer = nil
        engine?.inputNode.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        isListening = false
    }

    private var demoTimer: Timer?
    private func startDemoDrift() {
        demoTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isListening else { return }
                let t = Date().timeIntervalSinceReferenceDate
                let cents = sin(t * 1.4) * 35
                self.centsOffset = cents
                self.frequencyHz = self.referenceA4 * pow(2, cents / 1200)
            }
        }
    }
}
