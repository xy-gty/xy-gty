import SwiftUI
import FolioCueDomain

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ComplianceRibbon()
                    if let book = appModel.activeBookID {
                        Text("\(book.title) · coach")
                            .font(.headline)
                            .foregroundStyle(FolioCueTheme.ink)
                    }
                    ForEach(appModel.sessionTurns, id: \.createdAt) { turn in
                        HStack {
                            if turn.role == "coach" { Spacer(minLength: 40) }
                            Text(turn.text)
                                .font(.body)
                                .foregroundStyle(turn.role == "coach" ? FolioCueTheme.ink : Color.white)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(turn.role == "coach" ? FolioCueTheme.cardFace : FolioCueTheme.primary)
                                )
                            if turn.role == "user" { Spacer(minLength: 40) }
                        }
                    }
                    if appModel.coachBusy {
                        ProgressView("Coach thinking…")
                    }
                }
                .padding(16)
            }

            VStack(spacing: 8) {
                HStack {
                    TextField("Ask TBR / reading / where is the book", text: $appModel.coachQuestion)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        appModel.sendCoachQuestion()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FolioCueTheme.accent)
                    .disabled(appModel.coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                HStack {
                    Button(appModel.speechService.isListening ? "Stop speech" : "Speak cue") {
                        if appModel.speechService.isListening {
                            appModel.finishSpeechQuestion()
                        } else {
                            appModel.startSpeechQuestion()
                        }
                    }
                    .buttonStyle(.bordered)
                    Button("Mark reading") {
                        appModel.coachQuestion = "mark as reading"
                        appModel.sendCoachQuestion()
                    }
                    .buttonStyle(.bordered)
                }
                if !appModel.speechService.transcript.isEmpty {
                    Text(appModel.speechService.transcript)
                        .font(.caption)
                        .foregroundStyle(FolioCueTheme.muted)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .folioCueScreen()
        .navigationTitle("Coach")
        .accessibilityIdentifier("CoachChat")
    }
}
