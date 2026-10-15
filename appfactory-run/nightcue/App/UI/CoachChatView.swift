import NightCueDomain
import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(appModel.sessionMessages, id: \.id) { message in
                        HStack {
                            if message.role == "coach" { Spacer(minLength: 40) }
                            Text(message.text)
                                .padding(12)
                                .background(message.role == "coach" ? NightCueTheme.primary.opacity(0.12) : NightCueTheme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(NightCueTheme.ink)
                            if message.role != "coach" { Spacer(minLength: 40) }
                        }
                    }
                }
                .padding(16)
            }

            if appModel.coachBusy {
                ProgressView("Asking coach…")
                    .padding(.bottom, 8)
            }

            if let reason = appModel.aiUnavailableReason {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(NightCueTheme.primary)
                    .padding(.horizontal)
            }

            HStack {
                TextField("Ask about ISO, shutter, focus…", text: $appModel.coachQuestion, axis: .vertical)
                    .lineLimit(1 ... 3)
                    .padding(10)
                    .background(NightCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Button("Send") {
                    appModel.requestCoach()
                }
                .buttonStyle(.borderedProminent)
                .tint(NightCueTheme.primary)
                .disabled(appModel.coachBusy)
            }
            .padding(16)
        }
        .nightCueScreen()
        .navigationTitle("Coach chat")
    }
}
