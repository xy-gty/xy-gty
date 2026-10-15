import SwiftUI

struct HandsFreeTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Hands-free coach")
                .font(.title.bold())
                .foregroundStyle(YarnCueTheme.ink)

            Text("Large Play / Next keep both hands on the needles.")
                .foregroundStyle(YarnCueTheme.muted)

            NextRowStepBand(
                cues: appModel.stepLabels,
                currentIndex: appModel.ttsStepIndex
            ) { idx in
                appModel.ttsStepIndex = idx
                appModel.currentStepIndex = idx
            }

            if appModel.tts.isSpeaking {
                Label("Speaking…", systemImage: "waveform")
                    .foregroundStyle(YarnCueTheme.fuchsia)
            }

            Button {
                appModel.playHandsFree()
            } label: {
                Text("Play")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, minHeight: 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(YarnCueTheme.fuchsia)
            .accessibilityIdentifier("cta-tts-play")

            HStack(spacing: 12) {
                Button("Pause") { appModel.pauseHandsFree() }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, minHeight: 52)
                Button("Next step") { appModel.nextHandsFreeStep() }
                    .buttonStyle(.borderedProminent)
                    .tint(YarnCueTheme.lime)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }

            Spacer()
        }
        .padding(20)
        .yarnCueScreen()
        .navigationTitle("Hands-free")
    }
}
