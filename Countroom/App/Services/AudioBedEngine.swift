import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioBedEngine: ObservableObject {
    enum Kind: String, Hashable {
        case drone
        case metronome
    }

    @Published private(set) var isPlaying = false
    @Published var kind: Kind = .drone
    @Published var pitchHz: Double = 440
    @Published var bpm: Double = 80
    @Published var waveform: [CGFloat] = Array(repeating: 0.2, count: 48)

    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var phase: Double = 0
    private var tickPhase: Double = 0
    private var waveformTimer: Timer?

    func play() {
        stop()
        let engine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let kind = self.kind
        let hz = pitchHz
        let bpm = self.bpm
        var localPhase = phase
        var localTick = tickPhase
        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let buffer = abl[0].mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }
            let sampleRate = format.sampleRate
            for frame in 0 ..< Int(frameCount) {
                let sample: Float
                if kind == .drone {
                    sample = Float(sin(2 * Double.pi * hz * localPhase / sampleRate) * 0.18)
                    localPhase += 1
                } else {
                    let period = sampleRate * 60.0 / max(bpm, 1)
                    let inClick = (localTick.truncatingRemainder(dividingBy: period)) < (sampleRate * 0.02)
                    sample = inClick ? 0.35 : 0
                    localTick += 1
                }
                buffer[frame] = sample
            }
            return noErr
        }
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            self.engine = engine
            self.sourceNode = node
            self.phase = localPhase
            self.tickPhase = localTick
            isPlaying = true
            startWaveform()
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        waveformTimer?.invalidate()
        waveformTimer = nil
        sourceNode.map { engine?.detach($0) }
        sourceNode = nil
        engine?.stop()
        engine = nil
        isPlaying = false
        waveform = Array(repeating: 0.15, count: 48)
    }

    private func startWaveform() {
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 24.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPlaying else { return }
                var next = self.waveform
                let base = self.kind == .drone ? 0.35 : 0.25
                let pulse = abs(sin(Date().timeIntervalSinceReferenceDate * (self.kind == .drone ? 6 : self.bpm / 10)))
                next.removeFirst()
                next.append(CGFloat(base + pulse * 0.45))
                self.waveform = next
            }
        }
    }
}
