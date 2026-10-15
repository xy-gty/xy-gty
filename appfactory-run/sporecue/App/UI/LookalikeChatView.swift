import SwiftUI
import SporeCueDomain

struct LookalikeChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DisclaimerBanner()

                    if appModel.coachBusy {
                        StatusBanner(text: "Coach is thinking…", isError: false)
                    }

                    ForEach(appModel.sessionTurns, id: \.createdAt) { turn in
                        HStack {
                            if turn.role == "coach" { Spacer(minLength: 40) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(turn.role == "coach" ? "Coach" : "You")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(SporeCueTheme.muted)
                                Text(turn.text)
                                    .font(.body)
                                    .foregroundStyle(SporeCueTheme.ink)
                                if turn.sttSource == "speech" {
                                    Text("via speech")
                                        .font(.caption2)
                                        .foregroundStyle(SporeCueTheme.accent)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(turn.role == "coach" ? SporeCueTheme.stackSlot : SporeCueTheme.barFace)
                            )
                            if turn.role == "user" { Spacer(minLength: 40) }
                        }
                    }
                }
                .padding(16)
            }

            HStack(spacing: 8) {
                TextField("How does this differ from…", text: $appModel.coachQuestion)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { appModel.sendCoachQuestion() }
                Button {
                    if appModel.speechService.isListening {
                        appModel.finishSpeechQuestion()
                    } else {
                        appModel.startSpeechQuestion()
                    }
                } label: {
                    Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "mic.fill")
                        .foregroundStyle(SporeCueTheme.accent)
                }
                Button("Send") { appModel.sendCoachQuestion() }
                    .buttonStyle(.borderedProminent)
                    .tint(SporeCueTheme.accent)
            }
            .padding(12)
            .background(SporeCueTheme.barFace)
        }
        .sporeScreen()
        .navigationTitle("Lookalike chat")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("LookalikeChat")
    }
}
