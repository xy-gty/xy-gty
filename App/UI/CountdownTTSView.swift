import SwiftUI

struct CountdownTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TTS countdown cues")
                .font(.title3.bold())
                .foregroundStyle(StopCueTheme.ink)
            if appModel.sessionCues.isEmpty {
                Text("Keep a shot plan to generate countdown cues.")
                    .foregroundStyle(StopCueTheme.muted)
            } else {
                ForEach(Array(appModel.sessionCues.enumerated()), id: \.element.id) { idx, cue in
                    HStack {
                        Text("\(idx + 1).")
                            .foregroundStyle(StopCueTheme.accent)
                            .fontWeight(.bold)
                        Text(cue.text)
                            .foregroundStyle(StopCueTheme.ink)
                    }
                }
            }
            HStack {
                Button("Play") { appModel.playCountdownCues() }
                    .buttonStyle(.borderedProminent)
                    .tint(StopCueTheme.primary)
                Button("Pause") { appModel.pauseCountdownCues() }
                    .buttonStyle(.bordered)
                Button("Next") { appModel.nextCountdownCue() }
                    .buttonStyle(.bordered)
                    .tint(StopCueTheme.accent)
            }
            if appModel.tts.isSpeaking {
                Text("Speaking…").font(.caption).foregroundStyle(StopCueTheme.accent)
            }
            if let msg = appModel.statusMessage {
                Text(msg).font(.footnote).foregroundStyle(StopCueTheme.muted)
            }
            Spacer()
        }
        .padding(20)
        .stopCueScreen()
        .navigationTitle("Countdown")
    }
}
