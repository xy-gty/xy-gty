import ScoutCueDomain
import SwiftUI

struct NextStopBriefingView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("TTS next-stop shoot briefing")
                    .font(.title3.bold())
                    .foregroundStyle(ScoutCueTheme.ink)

                let clips = appModel.planBriefings
                if clips.isEmpty {
                    Text("Keep a scout card first to generate briefing clips.")
                        .foregroundStyle(ScoutCueTheme.muted)
                } else {
                    let idx = min(appModel.briefingIndex, clips.count - 1)
                    let clip = clips[idx]
                    VStack(alignment: .leading, spacing: 10) {
                        Label(clip.stopLabel, systemImage: "flag.fill")
                            .font(.headline)
                            .foregroundStyle(ScoutCueTheme.indigo)
                        Text(clip.spokenText)
                            .foregroundStyle(ScoutCueTheme.ink)
                        if appModel.tts.isSpeaking {
                            Label("Speaking…", systemImage: "waveform")
                                .foregroundStyle(ScoutCueTheme.rose)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: ScoutCueTheme.indigo.opacity(0.1), radius: 8, y: 3)
                }

                HStack(spacing: 12) {
                    Button { appModel.playBriefing() } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ScoutCueTheme.indigo)

                    Button { appModel.pauseBriefing() } label: {
                        Label("Pause", systemImage: "pause.fill")
                    }
                    .buttonStyle(.bordered)

                    Button { appModel.nextBriefing() } label: {
                        Label("Next", systemImage: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(ScoutCueTheme.rose)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(ScoutCueTheme.muted)
                }
            }
            .padding(20)
        }
        .scoutCueScreen()
        .navigationTitle("Next stop")
        .navigationBarTitleDisplayMode(.inline)
    }
}
