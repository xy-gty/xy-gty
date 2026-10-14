import ScoutCueDomain
import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Ask about sun, moon, or golden-hour timing for this scout.")
                    .foregroundStyle(ScoutCueTheme.muted)

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ScoutCueTheme.rose.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                ForEach(appModel.cardTurns, id: \.id) { turn in
                    bubble(turn.text, coach: turn.role == "coach")
                }

                TextField("When is the best golden-hour window?", text: $appModel.coachQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2 ... 4)

                TextField("Optional feedback for next call", text: $appModel.userFeedback)
                    .textFieldStyle(.roundedBorder)

                Button {
                    appModel.requestCoach()
                } label: {
                    if appModel.coachBusy {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Label("Ask coach", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(ScoutCueTheme.indigo)
                .disabled(appModel.coachBusy)

                Text("First live send shows consent. Keep / Discard on the reply draft.")
                    .font(.caption)
                    .foregroundStyle(ScoutCueTheme.muted)
            }
            .padding(20)
        }
        .scoutCueScreen()
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bubble(_ text: String, coach: Bool) -> some View {
        HStack {
            if !coach { Spacer(minLength: 40) }
            Text(text)
                .padding(12)
                .foregroundStyle(coach ? ScoutCueTheme.ink : Color.white)
                .background(coach ? Color.white : ScoutCueTheme.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if coach { Spacer(minLength: 40) }
        }
    }
}
