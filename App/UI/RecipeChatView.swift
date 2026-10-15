import SwiftUI
import MixCueDomain

struct RecipeChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let banner = appModel.statusMessage {
                        StatusBanner(text: banner, isError: appModel.statusIsError)
                    }
                    ForEach(appModel.sessionTurns, id: \.createdAt) { turn in
                        HStack {
                            if turn.role == "coach" { Spacer(minLength: 40) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(turn.role == "coach" ? "Coach" : "You")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(MixCueTheme.accent)
                                Text(turn.text)
                                    .font(.body)
                                    .foregroundStyle(MixCueTheme.ink)
                                if turn.sttSource == "speech" {
                                    Text("via speech")
                                        .font(.caption2)
                                        .foregroundStyle(MixCueTheme.muted)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(turn.role == "coach" ? MixCueTheme.cardFace : MixCueTheme.secondary)
                            )
                            if turn.role == "user" { Spacer(minLength: 40) }
                        }
                    }
                    if appModel.sessionTurns.isEmpty {
                        Text("Ask for a recipe or substitute — e.g. what can I sub for Cointreau.")
                            .font(.subheadline)
                            .foregroundStyle(MixCueTheme.muted)
                            .padding(.top, 24)
                    }
                }
                .padding(16)
            }

            VStack(spacing: 8) {
                HStack {
                    TextField("Recipe or substitute question", text: $appModel.coachQuestion)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.send)
                        .onSubmit { appModel.sendCoachQuestion() }
                    Button {
                        appModel.sendCoachQuestion()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(MixCueTheme.primary)
                    }
                    .disabled(appModel.coachBusy)
                    Button {
                        if appModel.speechService.isListening {
                            appModel.finishSpeechQuestion()
                        } else {
                            appModel.startSpeechQuestion()
                        }
                    } label: {
                        Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundStyle(MixCueTheme.accent)
                    }
                }
                Button("Open pour board") { appModel.openPourBoard() }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MixCueTheme.primary)
            }
            .padding(12)
            .background(MixCueTheme.cardFace)
        }
        .mixCueScreen()
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("RecipeChat")
    }
}
