import SwiftUI
import ZonelightDomain

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ComplianceBanner()
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(appModel.sessionTurns, id: \.createdAt) { turn in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(turn.role.capitalized)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(turn.role == "coach" ? ZonelightTheme.primary : ZonelightTheme.accent)
                                if !turn.strategy.isEmpty {
                                    Text(turn.strategy)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(ZonelightTheme.secondary))
                                }
                                if turn.sttSource != nil {
                                    Image(systemName: "mic.fill")
                                        .font(.caption2)
                                        .foregroundStyle(ZonelightTheme.accent)
                                }
                            }
                            Text(turn.text)
                                .font(.body)
                                .foregroundStyle(ZonelightTheme.ink)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(turn.role == "coach" ? ZonelightTheme.card : ZonelightTheme.secondary)
                        )
                    }
                }
                .padding(16)
            }

            if appModel.coachBusy {
                ProgressView("Coach thinking…")
                    .padding(.bottom, 4)
            }

            VStack(spacing: 8) {
                HStack {
                    TextField("Zone / film / digital question", text: $appModel.coachQuestion)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        appModel.sendCoachQuestion()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ZonelightTheme.primary)
                    .disabled(appModel.coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                HStack {
                    Button("Hold to speak") {
                        appModel.startSpeechQuestion()
                    }
                    .buttonStyle(.bordered)
                    Button("Send speech") {
                        appModel.finishSpeechQuestion()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ZonelightTheme.accent)
                    Button("Meter Card") { appModel.openMeterCard() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(16)
            .background(ZonelightTheme.secondary)
        }
        .luxScreen()
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("CoachChat")
    }
}
