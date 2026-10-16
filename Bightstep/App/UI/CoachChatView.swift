import SwiftUI
import BightstepDomain

struct CoachChatView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if let reason = model.aiUnavailableReason {
                        Text(reason)
                            .font(.footnote)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(BightstepTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    ForEach(model.coachTurns) { turn in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(turn.promptText).font(.subheadline.weight(.semibold))
                            Text(turn.responseText).font(.body)
                            if !turn.haulContext.isEmpty {
                                Text("Next haul: \(turn.haulContext)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(BightstepTheme.accent)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(BightstepTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(16)
            }
            VStack(spacing: 10) {
                HStack {
                    TextField("Ask next haul…", text: $model.chatText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    Button { model.startMicIntoChat() } label: {
                        Image(systemName: "mic.fill")
                    }
                    .accessibilityLabel("Microphone into coach chat")
                }
                Button(model.chatBusy ? "Planning next haul…" : "Send") {
                    model.sendCoachChatLocalDemoIfNeeded()
                }
                .buttonStyle(BightstepTheme.PrimaryButtonStyle())
                .disabled(model.chatBusy)
                Button("Make step overlay") { model.makeStepOverlay() }
                    .buttonStyle(BightstepTheme.SecondaryButtonStyle())
            }
            .padding(16)
            .background(BightstepTheme.secondary)
        }
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Coach")
    }
}
