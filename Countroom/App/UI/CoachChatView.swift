import SwiftUI
import AppRuntimeCore

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tell the coach your practice goal. Plans require Keep before they stick.")
                    .foregroundStyle(CountroomTheme.muted)

                TextField("Instrument goal", text: $appModel.userGoal, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                TextField("Coach question", text: $appModel.coachQuestion, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                TextField("Feedback for next call (optional)", text: $appModel.userFeedback)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)

                Button {
                    Task { await appModel.captureSpeechGoal() }
                } label: {
                    Label(appModel.speechBusy ? "Listening…" : "Speak goal", systemImage: "mic")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(appModel.speechBusy)

                if !appModel.speechTranscript.isEmpty {
                    Text("Speech: \(appModel.speechTranscript)")
                        .font(.caption)
                        .foregroundStyle(CountroomTheme.muted)
                }

                ForEach(appModel.sessionTurns, id: \.id) { turn in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(turn.role.capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CountroomTheme.violet)
                        Text(turn.text)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CountroomTheme.softCloud)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if appModel.coachBusy {
                    ProgressView("Asking coach…")
                    Button("Cancel") {
                        appModel.coachBusy = false
                        appModel.statusMessage = "Coach request cancelled."
                    }
                }

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(CountroomTheme.muted)
                }
                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(CountroomTheme.muted)
                }
            }
            .padding(20)
        } actions: {
            Button {
                focused = false
                appModel.requestCoach()
            } label: {
                Text("Ask coach")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(CountroomTheme.violet)
            .disabled(appModel.coachBusy)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .accessibilityLabel("Ask coach")
        }
        .countroomScreen()
        .navigationTitle("Coach chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}
