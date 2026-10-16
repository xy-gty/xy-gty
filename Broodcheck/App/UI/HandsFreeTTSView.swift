import SwiftUI

struct HandsFreeTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hands-free notes")
                    .font(.title2.bold())
                    .foregroundStyle(BroodcheckTheme.ink)

                Text("Play inspection notes while suited and gloved. Rail + comb grid sync on Next.")
                    .font(.subheadline)
                    .foregroundStyle(BroodcheckTheme.muted)

                InspectionRail(
                    steps: appModel.railSteps,
                    currentIndex: appModel.currentFrameIndex,
                    nextHint: appModel.nextRailHint,
                    onSelect: { appModel.selectFrame($0) }
                )

                HexCombGrid(
                    labels: appModel.frameLabels,
                    selectedIndex: appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                if appModel.tts.isSpeaking {
                    Label("Speaking…", systemImage: "waveform")
                        .foregroundStyle(BroodcheckTheme.accent)
                        .font(.headline)
                }

                HStack(spacing: 12) {
                    Button("Play") { appModel.playHandsFree() }
                        .buttonStyle(.borderedProminent)
                        .tint(BroodcheckTheme.primary)
                    Button("Pause") { appModel.pauseHandsFree() }
                        .buttonStyle(.bordered)
                    Button("Next note") { appModel.nextHandsFreeNote() }
                        .buttonStyle(.bordered)
                        .tint(BroodcheckTheme.accent)
                }

                ForEach(appModel.inspectionVoiceNotes, id: \.id) { note in
                    Text(note.text)
                        .font(.footnote)
                        .foregroundStyle(BroodcheckTheme.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(BroodcheckTheme.card)
                        )
                }
            }
            .padding(20)
        }
        .broodcheckScreen()
        .navigationTitle("Hands-free")
    }
}
