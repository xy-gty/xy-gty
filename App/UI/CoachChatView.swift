import SwiftUI
import AppRuntimeCore
import HiveCueDomain

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var questionFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { questionFocused = false }) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(appModel.inspectionMessages, id: \.id) { message in
                    HStack {
                        if message.role == "coach" { Spacer(minLength: 40) }
                        Text(message.text)
                            .font(.body)
                            .foregroundStyle(message.role == "coach" ? Color.white : HiveCueTheme.ink)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(message.role == "coach" ? HiveCueTheme.primary : HiveCueTheme.card)
                            )
                        if message.role != "coach" { Spacer(minLength: 40) }
                    }
                }
                if appModel.coachBusy {
                    ProgressView("Asking coach…")
                        .tint(HiveCueTheme.primary)
                }
                TextField("Ask for next hive action", text: $appModel.coachQuestion, axis: .vertical)
                    .focused($questionFocused)
                    .lineLimit(2 ... 4)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(HiveCueTheme.card)
                    )
            }
            .padding(16)
        } actions: {
            HStack {
                Button("Send") {
                    questionFocused = false
                    appModel.requestCoach()
                }
                .buttonStyle(.borderedProminent)
                .tint(HiveCueTheme.primary)
                .disabled(appModel.coachBusy)

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption2)
                        .foregroundStyle(HiveCueTheme.muted)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HiveCueTheme.secondary)
        }
        .hiveCueScreen()
        .navigationTitle("Coach chat")
    }
}
