import AVFoundation
import Foundation

/// Soft procedural beds (no copyrighted audio assets). Offline-safe.
@MainActor
final class AmbiencePlayer: ObservableObject {
    @Published var activeId: String? = "off"
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var timer: Timer?

    func use(presetId: String?) {
        stop()
        activeId = presetId ?? "off"
        guard let id = presetId, id != "off" else { return }
        startSoftTone(for: id)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        engine?.stop()
        player = nil
        engine = nil
    }

    private func startSoftTone(for id: String) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: 22_050, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.12
        do {
            try engine.start()
            player.play()
            self.engine = engine
            self.player = player
            scheduleBuffer(id: id, format: format)
            timer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.scheduleBuffer(id: id, format: format) }
            }
        } catch {
            stop()
        }
    }

    private func scheduleBuffer(id: String, format: AVAudioFormat) {
        guard let player else { return }
        let frames = AVAudioFrameCount(format.sampleRate * 1.8)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return }
        buffer.frameLength = frames
        let freq: Double
        switch id {
        case "soft_murmur": freq = 110
        case "rain_wings": freq = 220
        default: freq = 82
        }
        let rate = format.sampleRate
        if let ch = buffer.floatChannelData?[0] {
            for i in 0..<Int(frames) {
                let t = Double(i) / rate
                let noise = Double.random(in: -0.15...0.15)
                ch[i] = Float(sin(2 * Double.pi * freq * t) * 0.08 + noise * 0.03)
            }
        }
        player.scheduleBuffer(buffer, completionHandler: nil)
    }
}
