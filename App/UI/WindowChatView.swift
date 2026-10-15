import SwiftUI
import CellarCueDomain

struct WindowChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ComplianceBanner()

                    ForEach(Array(appModel.bottleTurns.enumerated()), id: \.offset) { _, turn in
                        HStack {
                            if turn.role == "user" { Spacer(minLength: 40) }
                            Text(turn.text)
                                .font(.body)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(turn.role == "user" ? CellarCueTheme.binFilled : Color.white)
                                )
                                .foregroundStyle(CellarCueTheme.ink)
                            if turn.role != "user" { Spacer(minLength: 40) }
                        }
                    }

                    if appModel.coachBusy {
                        Text("Coach is thinking…")
                            .font(.caption)
                            .foregroundStyle(CellarCueTheme.muted)
                    }
                }
                .padding(16)
            }

            HStack(spacing: 8) {
                TextField("Where is the 2015 Barolo? Pair with lamb?", text: $appModel.coachQuestion)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { appModel.sendCoachQuestion() }
                Button {
                    if appModel.speechService.isListening {
                        appModel.finishSpeechQuestion()
                    } else {
                        appModel.startSpeechQuestion()
                    }
                } label: {
                    Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "waveform")
                }
                Button("Send") { appModel.sendCoachQuestion() }
                    .foregroundStyle(CellarCueTheme.accent)
            }
            .padding(12)
            .background(CellarCueTheme.secondary)
        }
        .cellarScreen()
        .navigationTitle("Window & pairing")
        .navigationBarTitleDisplayMode(.inline)
    }
}
