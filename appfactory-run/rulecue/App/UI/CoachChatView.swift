import SwiftUI
import AppRuntimeCore

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(
            dismissFocus: { focused = false },
            content: {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(appModel.sessionMessages, id: \.id) { msg in
                        HStack {
                            if msg.role == "coach" { Spacer(minLength: 40) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(msg.role.capitalized)
                                    .font(.caption2)
                                    .foregroundStyle(RuleCueTheme.muted)
                                Text(msg.text)
                                    .foregroundStyle(RuleCueTheme.ink)
                            }
                            .padding(12)
                            .background(msg.role == "coach" ? RuleCueTheme.accent.opacity(0.12) : RuleCueTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            if msg.role != "coach" { Spacer(minLength: 40) }
                        }
                    }
                }
                .padding(16)
            },
            actions: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Zone: \(appModel.currentZoneLabel)")
                        .font(.caption)
                        .foregroundStyle(RuleCueTheme.accent)
                    TextField("Ask a ruling (e.g. can I play this card)", text: $appModel.coachQuestion, axis: .vertical)
                        .lineLimit(2 ... 4)
                        .focused($focused)
                        .padding(10)
                        .background(RuleCueTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    if appModel.coachBusy {
                        ProgressView("Sending…")
                    }
                    Button("Send") {
                        focused = false
                        appModel.requestCoach()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RuleCueTheme.primary)
                    .disabled(appModel.coachBusy)
                    if let reason = appModel.aiUnavailableReason {
                        Text(reason)
                            .font(.caption2)
                            .foregroundStyle(RuleCueTheme.muted)
                    }
                }
                .padding(16)
                .background(RuleCueTheme.secondary)
            }
        )
        .ruleCueScreen()
        .navigationTitle("Coach chat")
    }
}
