import SwiftUI

struct HandsFreeTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Hands-free callouts")
                    .font(.title2.bold())
                    .foregroundStyle(FormCueTheme.ink)

                IntervalChipRail(
                    blocks: appModel.chipLabels,
                    currentIndex: appModel.currentBlockIndex
                ) { idx in
                    appModel.ttsBlockIndex = idx
                    appModel.selectBlock(idx)
                }

                RestRing(
                    phaseLabel: appModel.activeSession?.currentBlockLabel ?? "Interval",
                    secondsRemaining: appModel.ringSecondsRemaining,
                    totalSeconds: appModel.ringTotalSeconds,
                    isRest: appModel.ringIsRest
                )

                HStack(spacing: 12) {
                    Button("Play") { appModel.playHandsFree() }
                        .buttonStyle(.borderedProminent)
                        .tint(FormCueTheme.primary)
                        .accessibilityIdentifier("cta-tts-play")
                    Button("Pause") { appModel.pauseHandsFree() }
                        .buttonStyle(.bordered)
                    Button("Next") { appModel.nextHandsFreeStep() }
                        .buttonStyle(.bordered)
                        .tint(FormCueTheme.accent)
                }

                if appModel.tts.isSpeaking {
                    Label("Speaking…", systemImage: "speaker.wave.2.fill")
                        .foregroundStyle(FormCueTheme.accent)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(FormCueTheme.ink)
                }
            }
            .padding(20)
        }
        .formCueScreen()
        .navigationTitle("Hands-free")
    }
}
