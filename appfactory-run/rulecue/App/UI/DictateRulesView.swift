import SwiftUI

struct DictateRulesView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dictate rules question")
                    .font(.title2.bold())
                    .foregroundStyle(RuleCueTheme.ink)
                Text("Microphone + speech recognition write into coach chat and advance the next tip.")
                    .foregroundStyle(RuleCueTheme.muted)

                TurnStepBar(
                    steps: appModel.sessionPhases,
                    currentIndex: appModel.currentStepIndex,
                    onSelect: { appModel.selectStep($0) }
                )

                if !appModel.speechTranscript.isEmpty {
                    Text("Heard: \(appModel.speechTranscript)")
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RuleCueTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                TextField("Or type the question", text: $appModel.coachQuestion, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .padding(12)
                    .background(RuleCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Button {
                    Task { await appModel.dictateRulesQuestion() }
                } label: {
                    Label(appModel.speechBusy ? "Listening…" : "Hold to dictate (tap)", systemImage: "mic.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(RuleCueTheme.primary)
                .disabled(appModel.speechBusy)

                Button("Open coach chat with text") {
                    appModel.push(.coachChat)
                }
                .buttonStyle(.bordered)
                .tint(RuleCueTheme.accent)

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(RuleCueTheme.muted)
                }

                Text("If mic/speech is denied, keep typing in the field above.")
                    .font(.caption)
                    .foregroundStyle(RuleCueTheme.muted)
            }
            .padding(20)
        }
        .ruleCueScreen()
        .navigationTitle("Dictate")
    }
}
