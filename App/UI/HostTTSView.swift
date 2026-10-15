import SwiftUI

struct HostTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Table-host cues")
                    .font(.title2.bold())
                    .foregroundStyle(RuleCueTheme.ink)
                Text("Hands-free TTS while you place components.")
                    .foregroundStyle(RuleCueTheme.muted)

                TurnStepBar(
                    steps: appModel.sessionPhases,
                    currentIndex: appModel.currentStepIndex,
                    onSelect: { appModel.selectStep($0) }
                )

                if appModel.sessionHostCues.isEmpty {
                    Text("No host cues yet. Keep a component draft to seed setup prompts.")
                        .foregroundStyle(RuleCueTheme.muted)
                } else {
                    ForEach(Array(appModel.sessionHostCues.enumerated()), id: \.element.id) { index, cue in
                        HStack(alignment: .top) {
                            Circle()
                                .fill(index == appModel.ttsCueIndex ? RuleCueTheme.accent : RuleCueTheme.primary.opacity(0.35))
                                .frame(width: 10, height: 10)
                                .padding(.top, 6)
                            Text(cue.text)
                                .foregroundStyle(RuleCueTheme.ink)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RuleCueTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }

                HStack(spacing: 12) {
                    Button("Play") { appModel.playHostCue() }
                        .buttonStyle(.borderedProminent)
                        .tint(RuleCueTheme.primary)
                    Button("Pause") { appModel.pauseHostCue() }
                        .buttonStyle(.bordered)
                    Button("Next cue") { appModel.nextHostCue() }
                        .buttonStyle(.bordered)
                        .tint(RuleCueTheme.accent)
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(RuleCueTheme.muted)
                }
            }
            .padding(20)
        }
        .ruleCueScreen()
        .navigationTitle("Host TTS")
    }
}
