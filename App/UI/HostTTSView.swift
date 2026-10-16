import SwiftUI

struct HostTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Setup lines")
                    .font(.title2.bold())
                    .foregroundStyle(TablehostTheme.ink)
                Text("Hands-free TTS while you place components.")
                    .foregroundStyle(TablehostTheme.muted)

                TurnStepBar(
                    steps: appModel.sessionPhases,
                    currentIndex: appModel.currentStepIndex,
                    onSelect: { appModel.selectStep($0) }
                )

                if appModel.sessionHostCues.isEmpty {
                    Text("No setup lines yet. Keep a component draft to seed setup prompts.")
                        .foregroundStyle(TablehostTheme.muted)
                } else {
                    ForEach(Array(appModel.sessionHostCues.enumerated()), id: \.element.id) { index, cue in
                        HStack(alignment: .top) {
                            Circle()
                                .fill(index == appModel.ttsCueIndex ? TablehostTheme.accent : TablehostTheme.primary.opacity(0.35))
                                .frame(width: 10, height: 10)
                                .padding(.top, 6)
                            Text(cue.text)
                                .foregroundStyle(TablehostTheme.ink)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(TablehostTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }

                HStack(spacing: 12) {
                    Button("Play") { appModel.playHostCue() }
                        .buttonStyle(.borderedProminent)
                        .tint(TablehostTheme.primary)
                    Button("Pause") { appModel.pauseHostCue() }
                        .buttonStyle(.bordered)
                    Button("Next line") { appModel.nextHostCue() }
                        .buttonStyle(.bordered)
                        .tint(TablehostTheme.accent)
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(TablehostTheme.muted)
                }
            }
            .padding(20)
        }
        .tablehostScreen()
        .navigationTitle("Host TTS")
    }
}
