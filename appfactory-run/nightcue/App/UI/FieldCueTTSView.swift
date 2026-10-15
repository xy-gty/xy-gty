import NightCueDomain
import SwiftUI

struct FieldCueTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hands-free field cues")
                .font(.title2.bold())
                .foregroundStyle(NightCueTheme.ink)

            Text("Stay on the tripod — play ISO / shutter / focus cues aloud.")
                .font(.subheadline)
                .foregroundStyle(NightCueTheme.muted)

            NightFrameRail(
                labels: appModel.frameLabels,
                selectedIndex: $appModel.currentFrameIndex,
                onSelect: { appModel.selectFrame($0) }
            )

            ForEach(Array(appModel.sessionCues.enumerated()), id: \.element.id) { index, cue in
                HStack {
                    Circle()
                        .fill(index == appModel.ttsCueIndex ? NightCueTheme.accent : NightCueTheme.primary.opacity(0.25))
                        .frame(width: 10, height: 10)
                    Text(cue.text)
                        .font(.body)
                        .foregroundStyle(NightCueTheme.ink)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(NightCueTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            HStack {
                Button("Play") { appModel.playFieldCues() }
                    .buttonStyle(.borderedProminent)
                    .tint(NightCueTheme.primary)
                Button("Pause") { appModel.pauseFieldCues() }
                    .buttonStyle(.bordered)
                Button("Next") { appModel.nextFieldCue() }
                    .buttonStyle(.bordered)
            }

            if appModel.tts.isSpeaking {
                Label("Speaking…", systemImage: "speaker.wave.2.fill")
                    .foregroundStyle(NightCueTheme.accent)
            }

            if let status = appModel.statusMessage {
                Text(status).font(.footnote).foregroundStyle(NightCueTheme.primary)
            }

            Spacer()
        }
        .padding(20)
        .nightCueScreen()
        .navigationTitle("Field cues")
    }
}
