import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(appModel.sessionMessages, id: \.id) { msg in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(msg.role.uppercased())
                                .font(.caption2.bold())
                                .foregroundStyle(OnionreelTheme.accent)
                            Text(msg.text)
                                .font(.body)
                                .foregroundStyle(OnionreelTheme.ink)
                                .padding(10)
                                .background(OnionreelTheme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
            TextField("Ask about shot plan / timing…", text: $appModel.coachQuestion, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button {
                appModel.requestCoach()
            } label: {
                if appModel.coachBusy {
                    ProgressView()
                } else {
                    Text("Send")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(OnionreelTheme.primary)
            .padding(.horizontal)
            .disabled(appModel.coachBusy)
            if let reason = appModel.aiUnavailableReason {
                Text(reason).font(.caption).foregroundStyle(OnionreelTheme.muted).padding(.horizontal)
            }
        }
        .padding(.bottom)
        .onionreelScreen()
        .navigationTitle("Coach chat")
    }
}
