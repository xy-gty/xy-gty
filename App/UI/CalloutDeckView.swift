import SwiftUI

struct CalloutDeckView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Callout deck")
                    .font(.title2.bold())
                    .foregroundStyle(FinishCueTheme.ink)

                Text("TTS start commands and time callouts. Works offline without AI.")
                    .font(.subheadline)
                    .foregroundStyle(FinishCueTheme.muted)

                HStack(spacing: 12) {
                    Button {
                        appModel.playStart()
                    } label: {
                        Label("Play start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(FinishCueTheme.primary, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .accessibilityIdentifier("PlayStart")

                    Button {
                        appModel.playTimes()
                    } label: {
                        Label("Play times", systemImage: "speaker.wave.2.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(FinishCueTheme.accent, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .accessibilityIdentifier("PlayTimes")
                }

                Button {
                    Task {
                        _ = await appModel.voiceRecorder.requestMicAccess()
                        let url = FileManager.default.temporaryDirectory
                            .appendingPathComponent("finishcue-mic-\(UUID().uuidString).m4a")
                        if appModel.voiceRecorder.isRecording {
                            appModel.voiceRecorder.stop()
                        } else {
                            appModel.voiceRecorder.start(to: url)
                        }
                    }
                } label: {
                    Label(
                        appModel.voiceRecorder.isRecording ? "Stop mic" : "Hands-free mic",
                        systemImage: "mic.fill"
                    )
                }
                .tint(FinishCueTheme.primary)
                .accessibilityIdentifier("HandsFreeMic")

                ForEach(appModel.heatCallouts, id: \.id) { cue in
                    Button {
                        appModel.playCallout(cue)
                    } label: {
                        HStack {
                            Text(cue.cueKind.uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(FinishCueTheme.accent)
                            Text(cue.text)
                                .foregroundStyle(FinishCueTheme.ink)
                            Spacer()
                            if cue.spokenAt != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(FinishCueTheme.accent)
                            }
                        }
                        .padding(12)
                        .background(FinishCueTheme.secondary, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                Button("Back to heats") { appModel.popToHome() }
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .finishCueScreen()
        .navigationTitle("Callouts")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appModel.ensureCallouts() }
        .accessibilityIdentifier("CalloutDeck")
    }
}
