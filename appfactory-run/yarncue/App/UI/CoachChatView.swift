import AppRuntimeCore
import SwiftUI
import YarnCueDomain

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var chatFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { chatFocused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Weave coach")
                    .font(.title2.bold())
                    .foregroundStyle(YarnCueTheme.ink)

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(YarnCueTheme.muted)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(YarnCueTheme.card))
                }

                ForEach(appModel.projectMessages.filter { $0.status == "confirmed" }, id: \.id) { message in
                    bubble(message)
                }

                TextField("Ask about the next row…", text: $appModel.coachQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($chatFocused)

                TextField("Feedback for next call (optional)", text: $appModel.userFeedback, axis: .vertical)
                    .textFieldStyle(.roundedBorder)

                if appModel.coachBusy {
                    ProgressView("Asking coach…")
                }
            }
            .padding(20)
        } actions: {
            HStack {
                Button {
                    Task { await appModel.startDictate() }
                } label: {
                    Label(appModel.speechBusy ? "Listening…" : "Mic", systemImage: "mic.fill")
                }
                .buttonStyle(.bordered)

                Button("Send") {
                    appModel.requestCoach()
                }
                .buttonStyle(.borderedProminent)
                .tint(YarnCueTheme.fuchsia)
                .disabled(appModel.coachBusy)
            }
            .padding()
        }
        .yarnCueScreen()
        .navigationTitle("Chat")
    }

    private func bubble(_ message: CoachMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.role.capitalized)
                .font(.caption.weight(.bold))
                .foregroundStyle(YarnCueTheme.fuchsia)
            Text(message.text)
                .foregroundStyle(YarnCueTheme.ink)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(YarnCueTheme.card))
    }
}
