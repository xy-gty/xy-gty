import SwiftUI
import CuePartnerDomain
import AppRuntimeCore

struct PartnerChatView: View {
    @EnvironmentObject private var model: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Scene partner")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CueTheme.ink)

                HStack {
                    TextField("Partner role", text: $model.partnerRole)
                        .textFieldStyle(.roundedBorder)
                    TextField("Your role", text: $model.userRole)
                        .textFieldStyle(.roundedBorder)
                }

                if let reason = model.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CueTheme.wood.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(model.activeMessages, id: \.id) { msg in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(msg.role)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(CueTheme.curtain)
                                Text(msg.text)
                                if !msg.feedbackNotes.isEmpty {
                                    Text("Feedback: \(msg.feedbackNotes.joined(separator: "; "))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.65))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
                .frame(minHeight: 180)

                TextField("Your line", text: $model.chatText, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)

                if model.chatBusy {
                    ProgressView("Waiting for partner…")
                }
            }
            .padding()
        } actions: {
            HStack {
                Button("Speak line") {
                    Task { await model.speakLineIntoChat() }
                }
                .buttonStyle(.bordered)
                .disabled(model.speechBusy)

                Button("Send") {
                    model.prepareSendPartner()
                }
                .buttonStyle(.borderedProminent)
                .tint(CueTheme.amber)
                .disabled(model.chatBusy)
            }
            .padding()
        }
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Partner")
        .sheet(item: Binding(
            get: { model.pendingTurn },
            set: { if $0 == nil { model.discardPendingTurn() } }
        )) { _ in
            NavigationStack {
                TurnReviewView()
                    .environmentObject(model)
            }
        }
    }
}
