import AVFoundation
import Foundation
import CuePartnerDomain

@MainActor
final class CueTTSPlayer: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var isPlaying = false
    @Published var remainingPauseMs: Int = 0

    private let synth = AVSpeechSynthesizer()
    private var lines: [CueLine] = []
    private var playTask: Task<Void, Never>?

    func load(_ lines: [CueLine]) {
        stop()
        self.lines = lines
        currentIndex = 0
    }

    func play() {
        guard !lines.isEmpty else { return }
        stop()
        isPlaying = true
        playTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled && self.isPlaying && self.currentIndex < self.lines.count {
                let line = self.lines[self.currentIndex]
                await self.speak(line.text)
                if Task.isCancelled || !self.isPlaying { break }
                let pause = max(0, line.pauseMilliseconds)
                self.remainingPauseMs = pause
                if pause > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(pause) * 1_000_000)
                }
                self.remainingPauseMs = 0
                if Task.isCancelled || !self.isPlaying { break }
                self.currentIndex += 1
            }
            self.isPlaying = false
        }
    }

    func pause() {
        isPlaying = false
        synth.stopSpeaking(at: .immediate)
        playTask?.cancel()
        playTask = nil
        remainingPauseMs = 0
    }

    func stop() {
        pause()
        currentIndex = 0
    }

    func next() {
        if currentIndex + 1 < lines.count {
            currentIndex += 1
        }
    }

    private func speak(_ text: String) async {
        let utter = AVSpeechUtterance(string: text)
        utter.rate = AVSpeechUtteranceDefaultSpeechRate
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utter)
        // Poll until finished or cancelled — keeps MainActor ownership simple.
        while synth.isSpeaking && isPlaying && !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
    }
}
