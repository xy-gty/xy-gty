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
                                    .foregroundStyle(TablehostTheme.muted)
                                Text(msg.text)
                                    .foregroundStyle(TablehostTheme.ink)
                            }
                            .padding(12)
                            .background(msg.role == "coach" ? TablehostTheme.accent.opacity(0.12) : TablehostTheme.card)
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
                        .foregroundStyle(TablehostTheme.accent)
                    TextField("Ask a ruling (e.g. can I play this card)", text: $appModel.coachQuestion, axis: .vertical)
                        .lineLimit(2 ... 4)
                        .focused($focused)
                        .padding(10)
                        .background(TablehostTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    if appModel.coachBusy {
                        ProgressView("Sending…")
                    }
                    Button("Send") {
                        focused = false
                        appModel.requestCoach()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(TablehostTheme.primary)
                    .disabled(appModel.coachBusy)
                    if let reason = appModel.aiUnavailableReason {
                        Text(reason)
                            .font(.caption2)
                            .foregroundStyle(TablehostTheme.muted)
                    }
                }
                .padding(16)
                .background(TablehostTheme.secondary)
            }
        )
        .tablehostScreen()
        .navigationTitle("Coach chat")
    }
}
