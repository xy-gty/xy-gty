import SwiftUI
import CuePartnerDomain

struct CueRehearsalView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Cue rehearsal")
                .font(.title2.weight(.bold))
                .foregroundStyle(CueTheme.ink)

            if model.activeCues.isEmpty {
                Text("Add cue lines before playing TTS.")
                    .foregroundStyle(.secondary)
            } else {
                let idx = min(model.tts.currentIndex, max(model.activeCues.count - 1, 0))
                ForEach(Array(model.activeCues.enumerated()), id: \.element.id) { offset, line in
                    HStack(alignment: .top) {
                        Circle()
                            .fill(offset == idx ? CueTheme.amber : CueTheme.curtain.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .padding(.top, 6)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.role).font(.caption.weight(.bold)).foregroundStyle(CueTheme.curtain)
                            Text(line.text)
                                .font(offset == idx ? .title3.weight(.semibold) : .body)
                                .foregroundStyle(CueTheme.ink)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(offset == idx ? CueTheme.amber.opacity(0.15) : Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if model.tts.isPlaying {
                    Text(model.tts.remainingPauseMs > 0
                         ? "Pause \(model.tts.remainingPauseMs) ms"
                         : "Speaking…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button("Play") {
                    model.tts.load(model.activeCues)
                    model.tts.play()
                }
                .buttonStyle(.borderedProminent)
                .tint(CueTheme.amber)
                .disabled(model.activeCues.isEmpty)

                Button("Pause") { model.tts.pause() }
                    .buttonStyle(.bordered)

                Button("Next") { model.tts.next() }
                    .buttonStyle(.bordered)
                    .disabled(model.activeCues.isEmpty)
            }
            Spacer()
        }
        .padding()
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Cues")
        .onDisappear { model.tts.pause() }
    }
}
