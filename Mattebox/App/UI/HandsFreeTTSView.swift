import SwiftUI

struct HandsFreeTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            ClapperFrameCanvas(
                title: "Hands-free",
                shotLabel: appModel.selectedChip,
                pulse: appModel.ttsPulse
            ) {
                VStack(spacing: 12) {
                    Image(systemName: "speaker.wave.2.bubble.left.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(MatteboxTheme.accent)
                    let cues = appModel.directorCues
                    let idx = min(appModel.ttsCueIndex, max(cues.count - 1, 0))
                    Text(cues.isEmpty ? "No lines yet" : cues[idx])
                        .multilineTextAlignment(.center)
                        .foregroundStyle(MatteboxTheme.ink)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            }

            ShotSizeChipBar(
                chips: appModel.chips,
                selected: appModel.selectedChip,
                onSelect: { appModel.selectChip($0) }
            )

            HStack(spacing: 12) {
                Button("Play") { appModel.playCurrentCue() }
                    .buttonStyle(.borderedProminent)
                    .tint(MatteboxTheme.accent)
                Button("Pause") { appModel.tts.pause() }
                    .buttonStyle(.bordered)
                Button("Next") { appModel.nextCue() }
                    .buttonStyle(.bordered)
            }

            if let err = appModel.tts.lastError {
                Text(err).font(.footnote).foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(16)
        .matteboxScreen()
        .navigationTitle("Hands-free TTS")
    }
}
