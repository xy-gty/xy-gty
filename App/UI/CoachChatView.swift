import AppRuntimeCore
import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var questionFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { questionFocused = false }) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Ask the form coach")
                    .font(.title2.bold())
                    .foregroundStyle(WorkrestTheme.ink)

                ForEach(appModel.sessionMessages.suffix(6), id: \.id) { message in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.role.capitalized)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(WorkrestTheme.muted)
                        Text(message.text)
                            .foregroundStyle(WorkrestTheme.ink)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(WorkrestTheme.card))
                }

                TextField("Plan or adjust intervals…", text: $appModel.coachQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($questionFocused)
                    .lineLimit(2...5)

                if appModel.coachBusy {
                    ProgressView("Coach thinking…")
                }

                if let reason = appModel.aiUnavailableReason {
                    Text(reason).font(.caption).foregroundStyle(WorkrestTheme.muted)
                }
            }
            .padding(20)
        } actions: {
            Button("Send") {
                appModel.requestCoach()
            }
            .buttonStyle(.borderedProminent)
            .tint(WorkrestTheme.primary)
            .padding()
            .disabled(appModel.coachBusy)
            .accessibilityIdentifier("cta-send-coach")
        }
        .workrestScreen()
        .navigationTitle("Coach chat")
    }
}
