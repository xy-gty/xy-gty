import SwiftUI

struct CountdownTTSView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Countdown lines")
                .font(.title3.bold())
                .foregroundStyle(OnionreelTheme.ink)
            if appModel.sessionCues.isEmpty {
                Text("Keep a shot plan to generate countdown lines.")
                    .foregroundStyle(OnionreelTheme.muted)
            } else {
                ForEach(Array(appModel.sessionCues.enumerated()), id: \.element.id) { idx, cue in
                    HStack {
                        Text("\(idx + 1).")
                            .foregroundStyle(OnionreelTheme.accent)
                            .fontWeight(.bold)
                        Text(cue.text)
                            .foregroundStyle(OnionreelTheme.ink)
                    }
                }
            }
            HStack {
                Button("Play") { appModel.playCountdownCues() }
                    .buttonStyle(.borderedProminent)
                    .tint(OnionreelTheme.primary)
                Button("Pause") { appModel.pauseCountdownCues() }
                    .buttonStyle(.bordered)
                Button("Next") { appModel.nextCountdownCue() }
                    .buttonStyle(.bordered)
                    .tint(OnionreelTheme.accent)
            }
            if appModel.tts.isSpeaking {
                Text("Speaking…").font(.caption).foregroundStyle(OnionreelTheme.accent)
            }
            if let msg = appModel.statusMessage {
                Text(msg).font(.footnote).foregroundStyle(OnionreelTheme.muted)
            }
            Spacer()
        }
        .padding(20)
        .onionreelScreen()
        .navigationTitle("Countdown")
    }
}
