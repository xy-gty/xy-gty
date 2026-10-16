import SwiftUI
import SpinewellDomain

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
                            .foregroundStyle(SpinewellTheme.ink)
                    }
                    ForEach(appModel.sessionTurns, id: \.createdAt) { turn in
                        HStack {
                            if turn.role == "coach" { Spacer(minLength: 40) }
                            Text(turn.text)
                                .font(.body)
                                .foregroundStyle(turn.role == "coach" ? SpinewellTheme.ink : Color.white)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(turn.role == "coach" ? SpinewellTheme.cardFace : SpinewellTheme.primary)
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
                    .tint(SpinewellTheme.accent)
                    .disabled(appModel.coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                HStack {
                    Button(appModel.speechService.isListening ? "Stop speech" : "Read aloud") {
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
                        .foregroundStyle(SpinewellTheme.muted)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .spinewellScreen()
        .navigationTitle("Coach")
        .accessibilityIdentifier("CoachChat")
    }
}
