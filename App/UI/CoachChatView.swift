import MatteboxDomain
import AppRuntimeCore
import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(
            dismissFocus: { focused = false },
            content: {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if let reason = appModel.aiUnavailableReason {
                        Text(reason)
                            .font(.footnote)
                            .foregroundStyle(MatteboxTheme.muted)
                            .padding(.bottom, 4)
                    }
                    ForEach(appModel.sessionMessages, id: \.id) { msg in
                        HStack {
                            if msg.role == "coach" { Spacer(minLength: 40) }
                            Text(msg.text)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(msg.role == "coach" ? MatteboxTheme.primary.opacity(0.12) : MatteboxTheme.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(MatteboxTheme.primary.opacity(0.2), lineWidth: 1)
                                )
                            if msg.role != "coach" { Spacer(minLength: 40) }
                        }
                    }
                    TextField("Shot size / aspect / lens language", text: $appModel.coachQuestion, axis: .vertical)
                        .lineLimit(2...4)
                        .focused($focused)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(MatteboxTheme.card))
                }
                .padding(16)
            },
            actions: {
                Button {
                    focused = false
                    appModel.requestCoach()
                } label: {
                    if appModel.coachBusy {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    } else {
                        Text("Send")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(MatteboxTheme.primary)
                .disabled(appModel.coachBusy)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        )
        .matteboxScreen()
        .navigationTitle("Coach")
    }
}
