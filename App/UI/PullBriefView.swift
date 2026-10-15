import SwiftUI
import CellarCueDomain

struct PullBriefView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                Text("TTS pull / pour brief")
                    .font(.title2.bold())
                    .foregroundStyle(CellarCueTheme.ink)

                if let brief = appModel.activeBrief {
                    Text(brief.scriptText)
                        .font(.body)
                        .foregroundStyle(CellarCueTheme.ink)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                        )

                    HStack {
                        Button(appModel.tts.isSpeaking ? "Speaking…" : "Play brief") {
                            appModel.playPullBrief()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CellarCueTheme.accent)
                        .disabled(appModel.tts.isSpeaking)

                        Button("Stop") { appModel.tts.stop() }
                            .buttonStyle(.bordered)
                    }
                } else {
                    Text("No brief yet — Identify a bottle first.")
                        .foregroundStyle(CellarCueTheme.muted)
                }
            }
            .padding(16)
        }
        .cellarScreen()
        .navigationTitle("Pull brief")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("PullBriefView")
    }
}
