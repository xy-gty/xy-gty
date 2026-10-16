import SunbriefDomain
import SwiftUI

struct NextStopBriefingView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("TTS next-stop shoot briefing")
                    .font(.title3.bold())
                    .foregroundStyle(SunbriefTheme.ink)

                let clips = appModel.planBriefings
                if clips.isEmpty {
                    Text("Keep a scout card first to generate briefing clips.")
                        .foregroundStyle(SunbriefTheme.muted)
                } else {
                    let idx = min(appModel.briefingIndex, clips.count - 1)
                    let clip = clips[idx]
                    VStack(alignment: .leading, spacing: 10) {
                        Label(clip.stopLabel, systemImage: "flag.fill")
                            .font(.headline)
                            .foregroundStyle(SunbriefTheme.indigo)
                        Text(clip.spokenText)
                            .foregroundStyle(SunbriefTheme.ink)
                        if appModel.tts.isSpeaking {
                            Label("Speaking…", systemImage: "waveform")
                                .foregroundStyle(SunbriefTheme.rose)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: SunbriefTheme.indigo.opacity(0.1), radius: 8, y: 3)
                }

                HStack(spacing: 12) {
                    Button { appModel.playBriefing() } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SunbriefTheme.indigo)

                    Button { appModel.pauseBriefing() } label: {
                        Label("Pause", systemImage: "pause.fill")
                    }
                    .buttonStyle(.bordered)

                    Button { appModel.nextBriefing() } label: {
                        Label("Next", systemImage: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(SunbriefTheme.rose)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(SunbriefTheme.muted)
                }
            }
            .padding(20)
        }
        .sunbriefScreen()
        .navigationTitle("Next stop")
        .navigationBarTitleDisplayMode(.inline)
    }
}
